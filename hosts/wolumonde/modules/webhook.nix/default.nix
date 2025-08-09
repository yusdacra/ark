{ config, tlib, ... }: let
  domain = "webhook.gaze.systems";
in {
  imports = tlib.importFolder ./.;

  services.webhook = {
    enable = true;
    urlPrefix = "";
  };

  age.secrets.webhookAuth = {
    file = ../../../../secrets/webhookAuth.age;
    mode = "600";
    owner = "nginx";
    group = "nginx";
  };

  security.acme.certs."gaze.systems".extraDomainNames = [domain];
  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    kTLS = true;
    quic = true;
    basicAuthFile = config.age.secrets.webhookAuth.path;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.webhook.port}";
    };
  };
}
