{ config, ... }:
let
  domain = "id.gaze.systems";
in
{
  services.pocket-id = {
    enable = true;
    settings = {
      APP_URL = "https://${domain}";
      TRUST_PROXY = true;
      PORT = 6823;
      ANALYTICS_DISABLED = true;
    };
  };

  security.acme.certs."gaze.systems".extraDomainNames = [ domain ];

  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/".proxyPass = "http://localhost:${toString config.services.pocket-id.settings.PORT}";
    locations."/".extraConfig = ''
      proxy_busy_buffers_size 512k;
      proxy_buffers 4 512k;
      proxy_buffer_size 256k;
    '';
  };
}
