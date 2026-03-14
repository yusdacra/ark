{
  inputs,
  ...
}:
{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    # /nginx_status
    statusPage = true;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

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
      '"requestTime":$request_time'
    '}';
    access_log /var/log/nginx/access.log json_logs;
  '';

  users.users.nginx.extraGroups = [ "acme" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = (import "${inputs.self}/personal.nix").emails.primary;
    defaults.webroot = "/var/lib/acme/acme-challenge";
    certs."plc.gaze.systems" = { };
  };

  services.nginx.virtualHosts."plc.gaze.systems" = {
    useACMEHost = "plc.gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://localhost:8000";
      proxyWebsockets = true;
    };
  };

  systemd.services.allegedly = {
    description = "allegedly mirror service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/root/allegedly2";
      ExecStart = "/root/allegedly2/target/release/allegedly mirror --wrap-fjall /root/plc3";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
