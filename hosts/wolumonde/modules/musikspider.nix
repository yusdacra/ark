{
  pkgs,
  inputs,
  ...
}: let
  pkg =
    inputs.musikspider.packages.${pkgs.system}.musikspider.overrideAttrs
    (old: {
      LOCAL_MUSIKQUAD_SERVER = "http://127.0.0.1:5005";
      PUBLIC_MUSIKQUAD_SERVER = "mq.gaze.systems";
      PUBLIC_BASEURL = "ms.gaze.systems";
    });
  port = "4004";
in {
  users.users.musikspider = {
    isSystemUser = true;
    group = "musikspider";
  };
  users.groups.musikspider = {};

  systemd.services.musikspider = {
    description = "musikspider";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      User = "musikspider";
      ExecStart = "${pkg}/bin/musikspider";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "/var/lib/musikspider";
      Environment = "HOME=/var/lib/musikspider";
      EnvironmentFile = pkgs.writeText "musikspider-env" ''
        PORT=${port}
      '';
    };
  };

  services.nginx.virtualHosts."ms.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${port}";
      proxyWebsockets = true;
    };
  };
}
