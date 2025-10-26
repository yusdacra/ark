{
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

  networking.firewall.allowedTCPPorts = [ 80 443 ];

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
    certs."vpn.gaze.systems" = { };
  };
}
