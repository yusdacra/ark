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
  systemd.services.nsid-tracker-client = {
    description = "nsid-tracker-client";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      # ORIGIN = "https://gaze.systems";
      PORT = toString port;
    };
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${client}/bin/website";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "/var/lib/nsid-tracker";
    };
  };
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
  systemd.timers.nsid-tracker-keep-alive.timerConfig = {
    OnBootSec = "5 min";
    OnUnitActiveSec = "5 min";
    Unit = "nsid-tracker-keep-alive.service";
  };

  services.nginx.virtualHosts."gaze.systems" = {
    locations."/nsid-tracker/api" = {
      proxyPass = "http://100.64.0.6:${toString port}/";
      proxyWebsockets = true;
      extraConfig = ''
        rewrite ^/nsid-tracker/api/(.*) /$1 break;
      '';
    };
    locations."/nsid-tracker".return = "301 /nsid-tracker/";
    locations."/nsid-tracker/" = {
      proxyPass = "http://localhost:${toString port}/";
      extraConfig = ''
        rewrite ^/nsid-tracker/(.*)$ /$1 break;
      '';
    };
  };
}
