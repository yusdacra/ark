{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    # /nginx_status
    statusPage = true;
  };

  # output json logs so we can consume them more easily
  services.nginx.appendHttpConfig = ''
    log_format json_logs escape=json '{'
      '"_msg":"request completed",'
      '"time":"$time_local",'
      '"req.remoteAddr":"$remote_addr",'
      '"req.method":"$request_method",'
      '"req.url":"$uri",'
      '"req.httpVersion":"$server_protocol",'
      '"res.statusCode":$status,'
      '"res.bodySize":$body_bytes_sent,'
      '"req.headers.id":"$request_id",'
      '"req.headers.referer":"$http_referer",'
      '"req.headers.user-agent":"$http_user_agent",'
      '"responseTime":$request_time'
    '}';
    access_log /var/log/nginx/access.log json_logs;
  '';

  users.users.nginx.extraGroups = [ "acme" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = (import "${inputs.self}/personal.nix").emails.primary;
    certs."gaze.systems" = {
      webroot = "/var/lib/acme/acme-challenge";
      extraDomainNames = [
        "git.gaze.systems"
        "test.gaze.systems"
        # "ms.gaze.systems"
        # "mq.gaze.systems"
        # "couchdb.gaze.systems"
        "doc.gaze.systems"
        "pmart.gaze.systems"
        "limbus.gaze.systems"
        # "bsky.gaze.systems"
        "dawn.gaze.systems"
        "guestbook.gaze.systems"
        "webhook.gaze.systems"
        "dash.gaze.systems"
      ];
    };
  };

  services.fluent-bit.settings = {
    parsers = [
      {
        name = "nginx_json";
        format = "json";
        time_key = "time";
        time_format = "%d/%b/%Y:%H:%M:%S %z";
      }
    ];
    pipeline = {
      inputs = [
        {
          name = "nginx_metrics";
          tag = "metrics.nginx";
          status_url = "/nginx_status";
          nginx_plus = false;
        }
        {
          name = "tail";
          tag = "logs.nginx";
          path = "/var/log/nginx/*.log";
          db = "/var/lib/fluent-bit/nginx-access.db";
          "db.locking" = true;
          buffer_chunk_size = "4m";
          buffer_max_size = "32m";
          parser = "nginx_json";
        }
      ];
    };
  };

  # need so fluent-bit can access nginx
  systemd.services.fluent-bit.serviceConfig.SupplementaryGroups = lib.mkForce "systemd-journal nginx";

  services.vmalert.rules.groups = [
    {
      name = "nginx-logs";
      type = "vlogs";
      interval = "1m";
      rules = [
        {
          record = "nginx_request_count";
          expr = "* | stats count() as requests";
        }
        {
          record = "nginx_2xx_count";
          expr = ''* | res.statusCode:~"2.." | stats count() as successes'';
        }
        {
          record = "nginx_5xx_count";
          expr = ''* | res.statusCode:~"5.." | stats count() as errors'';
        }
        {
          record = "nginx_request_latency_avg";
          expr = "* | stats avg(responseTime) as avg_latency";
        }
      ];
    }
  ];
}
