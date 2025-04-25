{config, ...}:
let
  grafanaCfg = config.services.grafana.settings;
in
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_port = 7412;
        enforce_domain = true;
        enable_gzip = true;
        domain = "dash.gaze.systems";
      };
      security = {
        cookie_secure = true;
      };
      analytics = {
        feedback_links_enabled = false;
        reporting_enabled = false;
      };
    };
  };

  services.nginx.virtualHosts.${grafanaCfg.server.domain} = {
    useACMEHost = "gaze.systems"; # TODO: write a module to define vhosts for subdomains
    quic = true;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString grafanaCfg.server.http_port}";
    };
  };
}
