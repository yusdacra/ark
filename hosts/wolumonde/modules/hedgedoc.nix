{ config, ... }: let
  cfg = config.services.hedgedoc.settings;
in
{
  services.hedgedoc = {
    enable = true;
    settings = {
      port = 3333;
      domain = "doc.gaze.systems";
      protocolUseSSL = true;
      allowEmailRegister = false;
      allowAnonymous = false;
      allowAnonymousEdits = true;
      allowFreeURL = true;
      requireFreeURLAuthentication = true;
    };
  };

  security.acme.certs."gaze.systems".extraDomainNames = [cfg.domain];
  services.nginx.virtualHosts.${cfg.domain} = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/".proxyPass =
      "http://${cfg.host}:${toString cfg.port}";
  };
}
