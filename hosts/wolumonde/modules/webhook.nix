{ config, tlib, ... }:
{
  imports = tlib.importFolder ./webhooks;

  services.webhook = {
    enable = true;
    urlPrefix = "";
  };

  age.secrets.webhookAuth = {
    file = ../../../secrets/webhookAuth.age;
    mode = "600";
    owner = "nginx";
    group = "nginx";
  };

  services.nginx.virtualHosts."webhook.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    basicAuthFile = config.age.secrets.webhookAuth.path;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.webhook.port}";
    };
  };
}
