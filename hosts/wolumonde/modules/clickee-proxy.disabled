{ config, terra, ... }:
let
  port = 7145;
in
{
  age.secrets.clickeeProxyConfig = {
    file = ../../../secrets/clickeeProxyConfig.age;
  };

  systemd.services.clickee-proxy = {
    description = "clickee-proxy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      PORT = toString port;
    };
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${terra.clickee-proxy}/bin/clickee-proxy";
      Restart = "on-failure";
      RestartSec = 5;
      EnvironmentFile = config.age.secrets.clickeeProxyConfig.path;
    };
  };

  services.nginx.virtualHosts."poor.dog" = {
    locations."/click".proxyPass = "http://localhost:${toString port}";
  };
}
