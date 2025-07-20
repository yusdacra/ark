{
  pkgs,
  inputs,
  ...
}:
let
  server = inputs.nsid-tracker.packages.${pkgs.system}.server;
  client = inputs.nsid-tracker.packages.${pkgs.system}.client.overrideAttrs (old: {
    PUBLIC_API_URL = "gaze.systems/nsid-tracker/api";
  });
  port = 6432;
in
{
  users.users.nsidtracker = {
    isSystemUser = true;
    home = "/mnt/data/nsid-tracker";
    createHome = true;
    group = "nsidtracker";
  };
  users.groups.nsidtracker = { };

  systemd.services.nsid-tracker = {
    description = "nsid-tracker";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      HOME = "/mnt/data/nsid-tracker";
      PORT = toString port;
    };
    serviceConfig = {
      User = "nsidtracker";
      ExecStart = "${server}/bin/server";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "/mnt/data/nsid-tracker";
    };
  };

  services.nginx.virtualHosts."gaze.systems" = {
    locations."/nsid-tracker/api" = {
      proxyPass = "http://localhost:${toString port}/";
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
