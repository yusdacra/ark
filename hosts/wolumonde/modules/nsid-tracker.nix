{
  pkgs,
  terra,
  inputs,
  ...
}:
let
  client-modules = pkgs.callPackage "${inputs.nsid-tracker}/nix/client-modules.nix" { };
  client = pkgs.callPackage "${inputs.nsid-tracker}/nix/client.nix" {
    PUBLIC_API_URL = "gaze.systems/nsid-tracker/api";
    inherit client-modules;
  };
  # server = terra.nsid-tracker-server;
  port = 3713;
in
{
  # users.users.nsidtracker = {
  #   isSystemUser = true;
  #   home = "/mnt/data/nsid-tracker";
  #   createHome = true;
  #   group = "nsidtracker";
  # };
  # users.groups.nsidtracker = { };

  # systemd.services.nsid-tracker = {
  #   description = "nsid-tracker";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   environment = {
  #     HOME = "/mnt/data/nsid-tracker";
  #     PORT = toString port;
  #   };
  #   serviceConfig = {
  #     User = "nsidtracker";
  #     ExecStart = "${server}/bin/server";
  #     Restart = "on-failure";
  #     RestartSec = 5;
  #     WorkingDirectory = "/mnt/data/nsid-tracker";
  #   };
  # };
  #

  systemd.services.nsid-tracker-keep-alive = {
    description = "keeps nsid-tracker peer connection alive";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.curl}/bin/curl http://dusk-devel-mobi:${toString port}/events";
    };
  };
  systemd.timers.nsid-tracker-keep-alive = {
    timerConfig = {
      OnCalendar = "*-*-* *:00/5:05";
      Unit = "nsid-tracker-keep-alive.service";
    };
  };

  services.nginx.virtualHosts."gaze.systems" = {
    locations."/nsid-tracker/api" = {
      proxyPass = "http://dusk-devel-mobi:${toString port}/";
      proxyWebsockets = true;
      extraConfig = ''
        rewrite ^/nsid-tracker/api/(.*) /$1 break;
      '';
    };
    locations."/nsid-tracker".return = "301 /nsid-tracker/";
    locations."/nsid-tracker/" = {
      alias = "${client}/";
      tryFiles = "$uri $uri/ /index.html";
    };
  };
}
