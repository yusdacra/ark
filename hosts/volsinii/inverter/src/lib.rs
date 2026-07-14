use std::{collections::BTreeMap, env, sync::Arc, time::Duration};

use anyhow::{Context, Result, bail};
use axum::{
    Router,
    body::{Body, Bytes},
    extract::{
        Path, Query, Request, State, WebSocketUpgrade,
        ws::{Message, WebSocket},
    },
    http::{HeaderMap, StatusCode, header},
    response::{IntoResponse, Response},
    routing::{any, get, post},
};
use reqwest::Client;
use serde::{Deserialize, Serialize};
use serde_cbor::Value;
use sha2::{Digest, Sha256};
use sqlx::{Row, SqlitePool, sqlite::SqlitePoolOptions};
use subtle::ConstantTimeEq;
use tokio::sync::broadcast;
use tower_http::trace::TraceLayer;
use tracing::{error, info};
use url::Url;

const MAX_FRAME_BYTES: usize = 5 * 1024 * 1024;
const REPLAY_PAGE_SIZE: i64 = 500;

#[derive(Clone, Debug)]
pub struct Config {
    pub listen: String,
    pub database_url: String,
    pub push_token: String,
    pub public_url: Url,
    pub upstream_url: Url,
    pub relay_urls: Vec<Url>,
}

impl Config {
    pub fn from_env() -> Result<Self> {
        let listen = env::var("INVERTER_LISTEN").unwrap_or_else(|_| "127.0.0.1:3000".into());
        let database_url = env::var("INVERTER_DATABASE_URL")
            .unwrap_or_else(|_| "sqlite://inverter.sqlite?mode=rwc".into());
        let push_token =
            env::var("INVERTER_PUSH_TOKEN").context("INVERTER_PUSH_TOKEN is required")?;
        if push_token.is_empty() {
            bail!("INVERTER_PUSH_TOKEN must not be empty");
        }
        let public_url = parse_base_url("INVERTER_PUBLIC_URL")?;
        let upstream_url = parse_base_url("INVERTER_UPSTREAM_URL")?;
        let relay_urls = env::var("INVERTER_RELAY_URLS")
            .unwrap_or_default()
            .split(',')
            .filter(|value| !value.trim().is_empty())
            .map(|value| Url::parse(value.trim()).context("invalid URL in INVERTER_RELAY_URLS"))
            .collect::<Result<Vec<_>>>()?;
        Ok(Self {
            listen,
            database_url,
            push_token,
            public_url,
            upstream_url,
            relay_urls,
        })
    }
}

fn parse_base_url(name: &str) -> Result<Url> {
    let value = env::var(name).with_context(|| format!("{name} is required"))?;
    let mut url = Url::parse(&value).with_context(|| format!("invalid {name}"))?;
    if !matches!(url.scheme(), "http" | "https") || url.host_str().is_none() {
        bail!("{name} must be an absolute HTTP(S) URL");
    }
    url.set_path("/");
    url.set_query(None);
    url.set_fragment(None);
    Ok(url)
}

#[derive(Clone)]
pub struct AppState {
    config: Arc<Config>,
    db: SqlitePool,
    client: Client,
    live: broadcast::Sender<Arc<StoredEvent>>,
}

#[derive(Debug)]
struct StoredEvent {
    seq: i64,
    frame: Bytes,
}

impl AppState {
    pub async fn new(config: Config) -> Result<Self> {
        let db = SqlitePoolOptions::new()
            .max_connections(8)
            .connect(&config.database_url)
            .await
            .context("opening inverter database")?;
        sqlx::query("PRAGMA journal_mode = WAL")
            .execute(&db)
            .await?;
        sqlx::query("PRAGMA synchronous = FULL")
            .execute(&db)
            .await?;
        sqlx::query(
            "CREATE TABLE IF NOT EXISTS events (\
                seq INTEGER PRIMARY KEY, \
                frame BLOB NOT NULL, \
                sha256 BLOB NOT NULL, \
                received_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP\
            )",
        )
        .execute(&db)
        .await?;
        let client = Client::builder()
            .connect_timeout(Duration::from_secs(10))
            .timeout(Duration::from_secs(30))
            .build()?;
        let (live, _) = broadcast::channel(1024);
        Ok(Self {
            config: Arc::new(config),
            db,
            client,
            live,
        })
    }
}

pub fn router(state: AppState) -> Router {
    Router::new()
        .route("/healthz", get(health))
        .route("/xrpc/net.klbr.inverter.getStatus", get(status))
        .route("/xrpc/net.klbr.inverter.pushEvent", post(push_event))
        .route(
            "/xrpc/com.atproto.sync.subscribeRepos",
            get(subscribe_repos),
        )
        .route("/xrpc/com.atproto.sync.requestCrawl", post(request_crawl))
        .route("/xrpc/{*path}", any(proxy_xrpc))
        .fallback(any(proxy_root))
        .layer(TraceLayer::new_for_http())
        .with_state(state)
}

async fn health() -> &'static str {
    "ok\n"
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct Status {
    event_count: i64,
    earliest_seq: Option<i64>,
    latest_seq: Option<i64>,
    upstream: String,
    relays: Vec<String>,
}

async fn status(State(state): State<AppState>) -> Result<impl IntoResponse, ApiError> {
    let row = sqlx::query("SELECT COUNT(*) count, MIN(seq) earliest, MAX(seq) latest FROM events")
        .fetch_one(&state.db)
        .await?;
    Ok(axum::Json(Status {
        event_count: row.get("count"),
        earliest_seq: row.get("earliest"),
        latest_seq: row.get("latest"),
        upstream: state.config.upstream_url.to_string(),
        relays: state
            .config
            .relay_urls
            .iter()
            .map(ToString::to_string)
            .collect(),
    }))
}

#[derive(Deserialize)]
struct PushQuery {
    seq: i64,
}

async fn push_event(
    State(state): State<AppState>,
    Query(query): Query<PushQuery>,
    headers: HeaderMap,
    body: Bytes,
) -> Result<impl IntoResponse, ApiError> {
    authorize(&headers, &state.config.push_token)?;
    if query.seq < 0 {
        return Err(ApiError::bad_request("seq must be non-negative"));
    }
    if body.len() > MAX_FRAME_BYTES {
        return Err(ApiError(
            StatusCode::PAYLOAD_TOO_LARGE,
            "frame exceeds 5 MiB".into(),
        ));
    }
    validate_frame(query.seq, &body)?;

    let digest = Sha256::digest(&body).to_vec();
    let mut tx = state.db.begin().await?;
    let existing = sqlx::query("SELECT sha256 FROM events WHERE seq = ?")
        .bind(query.seq)
        .fetch_optional(&mut *tx)
        .await?;
    if let Some(row) = existing {
        let existing_digest: Vec<u8> = row.get(0);
        if existing_digest == digest {
            tx.commit().await?;
            return Ok((
                StatusCode::OK,
                axum::Json(serde_json::json!({"seq": query.seq, "duplicate": true})),
            ));
        }
        return Err(ApiError(
            StatusCode::CONFLICT,
            "different frame already stored at seq".into(),
        ));
    }
    let latest: Option<i64> = sqlx::query_scalar("SELECT MAX(seq) FROM events")
        .fetch_one(&mut *tx)
        .await?;
    if latest.is_some_and(|latest| query.seq <= latest) {
        return Err(ApiError(
            StatusCode::CONFLICT,
            "seq is older than the latest stored event".into(),
        ));
    }
    sqlx::query("INSERT INTO events (seq, frame, sha256) VALUES (?, ?, ?)")
        .bind(query.seq)
        .bind(body.as_ref())
        .bind(digest)
        .execute(&mut *tx)
        .await?;
    tx.commit().await?;

    let event = Arc::new(StoredEvent {
        seq: query.seq,
        frame: body,
    });
    let _ = state.live.send(event);
    Ok((
        StatusCode::OK,
        axum::Json(serde_json::json!({"seq": query.seq, "duplicate": false})),
    ))
}

fn authorize(headers: &HeaderMap, expected: &str) -> Result<(), ApiError> {
    let supplied = headers
        .get(header::AUTHORIZATION)
        .and_then(|value| value.to_str().ok())
        .and_then(|value| value.strip_prefix("Bearer "))
        .unwrap_or_default();
    if supplied.as_bytes().ct_eq(expected.as_bytes()).into() {
        Ok(())
    } else {
        Err(ApiError(
            StatusCode::UNAUTHORIZED,
            "invalid bearer token".into(),
        ))
    }
}

fn validate_frame(expected_seq: i64, frame: &[u8]) -> Result<(), ApiError> {
    let mut de = serde_cbor::Deserializer::from_slice(frame);
    let header =
        Value::deserialize(&mut de).map_err(|_| ApiError::bad_request("invalid frame header"))?;
    let body =
        Value::deserialize(&mut de).map_err(|_| ApiError::bad_request("invalid frame body"))?;
    if de.byte_offset() != frame.len() {
        return Err(ApiError::bad_request("frame has trailing data"));
    }
    let Value::Map(header) = header else {
        return Err(ApiError::bad_request("frame header must be a map"));
    };
    let op = map_integer(&header, "op");
    let kind = map_text(&header, "t");
    if op != Some(1) || !matches!(kind, Some("#commit" | "#sync" | "#identity" | "#account")) {
        return Err(ApiError::bad_request(
            "unsupported AT Protocol message frame",
        ));
    }
    let Value::Map(body) = body else {
        return Err(ApiError::bad_request("frame body must be a map"));
    };
    if map_integer(&body, "seq") != Some(expected_seq as i128) {
        return Err(ApiError::bad_request("query seq does not match frame body"));
    }
    Ok(())
}

fn map_integer<'a>(map: &'a BTreeMap<Value, Value>, key: &str) -> Option<i128> {
    map.get(&Value::Text(key.into()))
        .and_then(|value| match value {
            Value::Integer(value) => Some(*value),
            _ => None,
        })
}

fn map_text<'a>(map: &'a BTreeMap<Value, Value>, key: &str) -> Option<&'a str> {
    map.get(&Value::Text(key.into()))
        .and_then(|value| match value {
            Value::Text(value) => Some(value.as_str()),
            _ => None,
        })
}

#[derive(Deserialize)]
struct SubscribeQuery {
    cursor: Option<i64>,
}

async fn subscribe_repos(
    ws: WebSocketUpgrade,
    State(state): State<AppState>,
    Query(query): Query<SubscribeQuery>,
) -> Response {
    ws.on_upgrade(move |socket| stream_events(socket, state, query.cursor))
}

async fn stream_events(mut socket: WebSocket, state: AppState, cursor: Option<i64>) {
    // Subscribe before taking the high-water mark so no committed event can fall between replay and live mode.
    let mut live = state.live.subscribe();
    let bounds = event_bounds(&state.db).await;
    let (earliest, high_water) = match bounds {
        Ok(bounds) => bounds,
        Err(err) => {
            error!(?err, "failed to read event bounds");
            return;
        }
    };
    let mut last_sent = cursor.unwrap_or(high_water.unwrap_or(-1));
    if cursor.is_some_and(|cursor| high_water.is_some_and(|high| cursor > high)) {
        let _ = socket
            .send(Message::Binary(
                error_frame("FutureCursor", "Cursor is newer than the latest event").into(),
            ))
            .await;
        return;
    }
    if let (Some(cursor), Some(first)) = (cursor, earliest) {
        if cursor < first - 1 {
            if socket
                .send(Message::Binary(
                    info_frame("OutdatedCursor", "Requested cursor is no longer available").into(),
                ))
                .await
                .is_err()
            {
                return;
            }
            last_sent = first - 1;
        }
    }
    if let Some(high_water) = high_water {
        if replay_range(&mut socket, &state.db, &mut last_sent, high_water)
            .await
            .is_err()
        {
            return;
        }
    }

    loop {
        match live.recv().await {
            Ok(event) if event.seq > last_sent => {
                if socket
                    .send(Message::Binary(event.frame.clone()))
                    .await
                    .is_err()
                {
                    return;
                }
                last_sent = event.seq;
            }
            Ok(_) => {}
            Err(broadcast::error::RecvError::Lagged(_)) => {
                let latest = match latest_seq(&state.db).await {
                    Ok(value) => value,
                    Err(_) => return,
                };
                if let Some(latest) = latest {
                    if replay_range(&mut socket, &state.db, &mut last_sent, latest)
                        .await
                        .is_err()
                    {
                        return;
                    }
                }
            }
            Err(broadcast::error::RecvError::Closed) => return,
        }
    }
}

async fn event_bounds(db: &SqlitePool) -> Result<(Option<i64>, Option<i64>), sqlx::Error> {
    let row = sqlx::query("SELECT MIN(seq) earliest, MAX(seq) latest FROM events")
        .fetch_one(db)
        .await?;
    Ok((row.get("earliest"), row.get("latest")))
}

async fn latest_seq(db: &SqlitePool) -> Result<Option<i64>, sqlx::Error> {
    sqlx::query_scalar("SELECT MAX(seq) FROM events")
        .fetch_one(db)
        .await
}

async fn replay_range(
    socket: &mut WebSocket,
    db: &SqlitePool,
    last_sent: &mut i64,
    high_water: i64,
) -> Result<(), ()> {
    while *last_sent < high_water {
        let rows = sqlx::query(
            "SELECT seq, frame FROM events WHERE seq > ? AND seq <= ? ORDER BY seq LIMIT ?",
        )
        .bind(*last_sent)
        .bind(high_water)
        .bind(REPLAY_PAGE_SIZE)
        .fetch_all(db)
        .await
        .map_err(|err| {
            error!(?err, "replay query failed");
        })?;
        if rows.is_empty() {
            break;
        }
        for row in rows {
            let seq: i64 = row.get("seq");
            let frame: Vec<u8> = row.get("frame");
            socket
                .send(Message::Binary(frame.into()))
                .await
                .map_err(|_| ())?;
            *last_sent = seq;
        }
    }
    Ok(())
}

fn cbor_frame(header: Value, body: Value) -> Vec<u8> {
    let mut frame = serde_cbor::to_vec(&header).expect("static CBOR header");
    frame.extend(serde_cbor::to_vec(&body).expect("static CBOR body"));
    frame
}

fn info_frame(name: &str, message: &str) -> Vec<u8> {
    cbor_frame(
        Value::Map(BTreeMap::from([
            (Value::Text("op".into()), Value::Integer(1)),
            (Value::Text("t".into()), Value::Text("#info".into())),
        ])),
        Value::Map(BTreeMap::from([
            (Value::Text("name".into()), Value::Text(name.into())),
            (Value::Text("message".into()), Value::Text(message.into())),
        ])),
    )
}

fn error_frame(error: &str, message: &str) -> Vec<u8> {
    cbor_frame(
        Value::Map(BTreeMap::from([(
            Value::Text("op".into()),
            Value::Integer(-1),
        )])),
        Value::Map(BTreeMap::from([
            (Value::Text("error".into()), Value::Text(error.into())),
            (Value::Text("message".into()), Value::Text(message.into())),
        ])),
    )
}

#[derive(Deserialize)]
struct CrawlRequest {
    hostname: String,
}

async fn request_crawl(
    State(state): State<AppState>,
    axum::Json(request): axum::Json<CrawlRequest>,
) -> Result<impl IntoResponse, ApiError> {
    info!(requested_hostname = %request.hostname, advertised_hostname = %state.config.public_url, "forwarding crawl request through inverter");
    if state.config.relay_urls.is_empty() {
        return Err(ApiError(
            StatusCode::SERVICE_UNAVAILABLE,
            "no relays configured".into(),
        ));
    }
    let advertised = state
        .config
        .public_url
        .host_str()
        .expect("validated public URL");
    for relay in &state.config.relay_urls {
        let endpoint = relay
            .join("xrpc/com.atproto.sync.requestCrawl")
            .expect("valid relative URL");
        let response = state
            .client
            .post(endpoint.clone())
            .json(&serde_json::json!({"hostname": advertised}))
            .send()
            .await
            .map_err(|err| {
                ApiError(
                    StatusCode::BAD_GATEWAY,
                    format!("relay {endpoint} failed: {err}"),
                )
            })?;
        if !response.status().is_success() {
            return Err(ApiError(
                StatusCode::BAD_GATEWAY,
                format!("relay {endpoint} returned {}", response.status()),
            ));
        }
    }
    Ok(StatusCode::OK)
}

async fn proxy_xrpc(
    State(state): State<AppState>,
    Path(path): Path<String>,
    request: Request,
) -> Result<Response, ApiError> {
    proxy(state, format!("xrpc/{path}"), request).await
}

async fn proxy_root(State(state): State<AppState>, request: Request) -> Result<Response, ApiError> {
    proxy(
        state,
        request.uri().path().trim_start_matches('/').to_owned(),
        request,
    )
    .await
}

async fn proxy(state: AppState, path: String, request: Request) -> Result<Response, ApiError> {
    let (parts, body) = request.into_parts();
    let mut url = state
        .config
        .upstream_url
        .join(&path)
        .map_err(|_| ApiError::bad_request("invalid proxy path"))?;
    url.set_query(parts.uri.query());
    let bytes = axum::body::to_bytes(body, MAX_FRAME_BYTES * 4)
        .await
        .map_err(|err| ApiError::bad_request(format!("failed to read request body: {err}")))?;
    let mut upstream = state.client.request(parts.method.clone(), url);
    for (name, value) in &parts.headers {
        if name != header::HOST && name != header::CONNECTION && name != header::UPGRADE {
            upstream = upstream.header(name, value);
        }
    }
    let response = upstream.body(bytes).send().await.map_err(|err| {
        ApiError(
            StatusCode::BAD_GATEWAY,
            format!("upstream request failed: {err}"),
        )
    })?;
    let status = response.status();
    let headers = response.headers().clone();
    let mut result = Response::new(Body::from_stream(response.bytes_stream()));
    *result.status_mut() = status;
    for (name, value) in headers {
        if let Some(name) = name {
            if name != header::TRANSFER_ENCODING && name != header::CONNECTION {
                result.headers_mut().insert(name, value);
            }
        }
    }
    Ok(result)
}

#[derive(Debug)]
struct ApiError(StatusCode, String);

impl ApiError {
    fn bad_request(message: impl Into<String>) -> Self {
        Self(StatusCode::BAD_REQUEST, message.into())
    }
}

impl From<sqlx::Error> for ApiError {
    fn from(error: sqlx::Error) -> Self {
        error!(?error, "database request failed");
        Self(
            StatusCode::INTERNAL_SERVER_ERROR,
            "database request failed".into(),
        )
    }
}

impl IntoResponse for ApiError {
    fn into_response(self) -> Response {
        (
            self.0,
            axum::Json(serde_json::json!({"error": self.0.canonical_reason(), "message": self.1})),
        )
            .into_response()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn message_frame(seq: i64, value: &str) -> Vec<u8> {
        cbor_frame(
            Value::Map(BTreeMap::from([
                (Value::Text("op".into()), Value::Integer(1)),
                (Value::Text("t".into()), Value::Text("#identity".into())),
            ])),
            Value::Map(BTreeMap::from([
                (Value::Text("seq".into()), Value::Integer(seq as i128)),
                (Value::Text("did".into()), Value::Text(value.into())),
            ])),
        )
    }

    #[test]
    fn validates_seq_and_rejects_trailing_data() {
        let frame = message_frame(7, "did:plc:test");
        validate_frame(7, &frame).unwrap();
        assert!(validate_frame(8, &frame).is_err());
        let mut trailing = frame;
        trailing.push(0xf6);
        assert!(validate_frame(7, &trailing).is_err());
    }
}
