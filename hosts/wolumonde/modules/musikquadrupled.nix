{
  config,
  inputs,
  pkgs,
  ...
}: let
  pkg = inputs.musikquad.packages.${pkgs.system}.default;
in {
  users.users.musikquad = {
    isSystemUser = true;
    group = "musikquad";
  };
  users.groups.musikquad = {};

  systemd.services.musikquadrupled = {
    description = "musikquadrupled";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      User = "musikquad";
      ExecStart = "${pkg}/bin/musikquadrupled";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "/var/lib/musikquad";
      EnvironmentFile = config.age.secrets.musikquadConfig.path;
    };
  };

  services.nginx.virtualHosts."mq.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:5005";
      proxyWebsockets = true;
    };
  };
}
