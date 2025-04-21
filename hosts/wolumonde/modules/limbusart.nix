{
  inputs,
  pkgs,
  lib,
  ...
}: let
  pkg = inputs.limbusart.packages.${pkgs.system}.default;
in {
  systemd.services.limbusart = {
    description = "limbusart";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = lib.mkMerge [
      {
        User = "limbusart";
        ExecStart = "${pkg}/bin/limbusart";
        Restart = "on-failure";
        RestartSec = 5;
        WorkingDirectory = "/var/lib/limbusart";
        EnvironmentFile = pkgs.writeText "limbusart.conf" ''
          ARTS_PATH="arts.txt"
          SITE_TITLE="random pm art"
          EMBED_TITLE="random pm art here!!"
          EMBED_DESC="click NOW to see random pm art"
          EMBED_COLOR="#bd0000"
        '';
      }
    ];
  };
  users.users.limbusart = {
    isSystemUser = true;
    group = "limbusart";
  };
  users.groups.limbusart = {};

  services.nginx.virtualHosts."pmart.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/".proxyPass = "http://localhost:3000";
  };
  # redirects
  services.nginx.virtualHosts."limbus.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    globalRedirect = "pmart.gaze.systems";
  };
}
