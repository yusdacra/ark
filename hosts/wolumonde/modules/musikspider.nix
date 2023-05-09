{
  pkgs,
  inputs,
  ...
}: let
  pkg =
    inputs.musikspider.packages.${pkgs.system}.musikspider.overrideAttrs
    (old: {
      LOCAL_MUSIKQUAD_SERVER = "http://localhost:5005";
      PUBLIC_MUSIKQUAD_SERVER = "mq.gaze.systems";
      PUBLIC_BASEURL = "ms.gaze.systems";
    });
in {
  users.users.musikspider = {
    isSystemUser = true;
    group = "musikspider";
  };
  users.groups.musikspider = {};

  systemd.services.musikspider= {
    description = "musikspider";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      User = "musikspider";
      ExecStart = "${pkgs.deno}/bin/deno run --allow-env --allow-read --allow-net ${pkg}/index.js";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "/var/lib/musikspider";
      EnvironmentFile = pkgs.writeText "musikspider-env" ''
        DENO_NO_UPDATE_CHECK=1
        DENO_DIR=/var/lib/musikspider/.deno
        PORT=4004
      '';
    };
  };

  services.nginx.virtualHosts."ms.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:4004";
      proxyWebsockets = true;
    };
  };
}
