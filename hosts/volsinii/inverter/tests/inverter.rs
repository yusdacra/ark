use std::collections::BTreeMap;

use axum::{
    Json, Router,
    extract::State,
    routing::{get, post},
};
use futures_util::{SinkExt, StreamExt};
use inverter::{AppState, Config, router};
use reqwest::StatusCode;
use serde_cbor::Value;
use tempfile::TempDir;
use tokio::{net::TcpListener, sync::mpsc};
use tokio_tungstenite::{connect_async, tungstenite::Message};
use url::Url;

fn frame(seq: i64, did: &str) -> Vec<u8> {
    let mut bytes = serde_cbor::to_vec(&Value::Map(BTreeMap::from([
        (Value::Text("op".into()), Value::Integer(1)),
        (Value::Text("t".into()), Value::Text("#identity".into())),
    ])))
    .unwrap();
    bytes.extend(
        serde_cbor::to_vec(&Value::Map(BTreeMap::from([
            (Value::Text("seq".into()), Value::Integer(seq as i128)),
            (Value::Text("did".into()), Value::Text(did.into())),
            (
                Value::Text("time".into()),
                Value::Text("2026-07-14T00:00:00.000Z".into()),
            ),
        ])))
        .unwrap(),
    );
    bytes
}

async fn spawn(app: Router) -> String {
    let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
    let address = listener.local_addr().unwrap();
    tokio::spawn(async move { axum::serve(listener, app).await.unwrap() });
    format!("http://{address}/")
}

#[tokio::test]
async fn persists_replays_streams_proxies_and_redirects_crawl() {
    let upstream = spawn(Router::new().route(
        "/xrpc/com.atproto.sync.listRepos",
        get(|| async { Json(serde_json::json!({"repos": [{"did": "did:plc:upstream"}]})) }),
    ))
    .await;

    let (crawl_tx, mut crawl_rx) = mpsc::channel(1);
    let relay = spawn(
        Router::new()
            .route(
                "/xrpc/com.atproto.sync.requestCrawl",
                post(
                    |State(tx): State<mpsc::Sender<String>>,
                     Json(body): Json<serde_json::Value>| async move {
                        tx.send(body["hostname"].as_str().unwrap().to_owned())
                            .await
                            .unwrap();
                        StatusCode::OK
                    },
                ),
            )
            .with_state(crawl_tx),
    )
    .await;

    let temporary = TempDir::new().unwrap();
    let config = Config {
        listen: "127.0.0.1:0".into(),
        database_url: format!(
            "sqlite://{}?mode=rwc",
            temporary.path().join("events.sqlite").display()
        ),
        push_token: "test-token".into(),
        public_url: Url::parse("https://inverter.example/").unwrap(),
        upstream_url: Url::parse(&upstream).unwrap(),
        relay_urls: vec![Url::parse(&relay).unwrap()],
    };
    let inverter = spawn(router(AppState::new(config).await.unwrap())).await;
    let client = reqwest::Client::new();
    let event1 = frame(1, "did:plc:first");
    let push1 = format!("{inverter}xrpc/net.klbr.inverter.pushEvent?seq=1");

    assert_eq!(
        client
            .post(&push1)
            .body(event1.clone())
            .send()
            .await
            .unwrap()
            .status(),
        StatusCode::UNAUTHORIZED
    );
    let response = client
        .post(&push1)
        .bearer_auth("test-token")
        .body(event1.clone())
        .send()
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::OK);
    assert_eq!(
        response.json::<serde_json::Value>().await.unwrap()["duplicate"],
        false
    );
    let response = client
        .post(&push1)
        .bearer_auth("test-token")
        .body(event1.clone())
        .send()
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::OK);
    assert_eq!(
        response.json::<serde_json::Value>().await.unwrap()["duplicate"],
        true
    );
    assert_eq!(
        client
            .post(&push1)
            .bearer_auth("test-token")
            .body(frame(1, "did:plc:conflict"))
            .send()
            .await
            .unwrap()
            .status(),
        StatusCode::CONFLICT,
    );

    let websocket_url =
        inverter.replace("http://", "ws://") + "xrpc/com.atproto.sync.subscribeRepos?cursor=0";
    let (mut websocket, _) = connect_async(websocket_url).await.unwrap();
    let replayed = websocket.next().await.unwrap().unwrap();
    assert_eq!(replayed.into_data(), event1);

    let event2 = frame(2, "did:plc:live");
    let response = client
        .post(format!("{inverter}xrpc/net.klbr.inverter.pushEvent?seq=2"))
        .bearer_auth("test-token")
        .body(event2.clone())
        .send()
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::OK);
    let live = websocket.next().await.unwrap().unwrap();
    assert_eq!(live.into_data(), event2);
    websocket.send(Message::Close(None)).await.unwrap();

    let proxied = client
        .get(format!("{inverter}xrpc/com.atproto.sync.listRepos"))
        .send()
        .await
        .unwrap()
        .json::<serde_json::Value>()
        .await
        .unwrap();
    assert_eq!(proxied["repos"][0]["did"], "did:plc:upstream");

    let response = client
        .post(format!("{inverter}xrpc/com.atproto.sync.requestCrawl"))
        .json(&serde_json::json!({"hostname": "pds.invalid"}))
        .send()
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::OK);
    assert_eq!(crawl_rx.recv().await.unwrap(), "inverter.example");

    let status = client
        .get(format!("{inverter}xrpc/net.klbr.inverter.getStatus"))
        .send()
        .await
        .unwrap()
        .json::<serde_json::Value>()
        .await
        .unwrap();
    assert_eq!(status["eventCount"], 2);
    assert_eq!(status["earliestSeq"], 1);
    assert_eq!(status["latestSeq"], 2);
}
