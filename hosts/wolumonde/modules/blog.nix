{
  config,
  pkgs,
  inputs,
  ...
}:
let
  PUBLIC_BASE_URL = "https://gaze.systems";
  modules = (pkgs.callPackage "${inputs.blog}/nix/modules.nix" { }).overrideAttrs (_: {
    outputHash = "sha256-CO0bFv5WbNBSgucHCb+I9kIZEkh6QqWngRra0luMtSI=";
  });
  pkg = pkgs.callPackage "${inputs.blog}/nix" {
    inherit PUBLIC_BASE_URL;
    gazesys-modules = modules;
  };
  port = 3003;
in
{
  users.users.website = {
    isSystemUser = true;
    group = "website";
  };
  users.groups.website = { };

  systemd.services.website = {
    description = "website";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      HOME = "/var/lib/website";
      ORIGIN = PUBLIC_BASE_URL;
      PORT = toString port;
      WEBSITE_DATA_DIR = "/var/lib/website";
      VITE_CLOUDINARY_CLOUD_NAME = "dgtwf7mar";
    };
    serviceConfig = {
      User = "website";
      ExecStart = "${pkg}/bin/website";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "/var/lib/website";
      EnvironmentFile = config.age.secrets.websiteConfig.path;
    };
  };

  # systemd.services.annoy-keep-alive = {
  #   description = "keeps annoy peer connection alive";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.curl}/bin/curl http://100.64.0.1:3111/";
  #   };
  # };
  # systemd.timers.annoy-keep-alive.timerConfig = {
  #   OnBootSec = "5 min";
  #   OnUnitActiveSec = "5 min";
  #   Unit = "annoy-keep-alive.service";
  # };

  services.nginx.virtualHosts."gaze.systems" = {
    locations."/".proxyPass = "http://localhost:${toString port}";
    locations."/annoy/ws/" = {
      proxyWebsockets = true;
      proxyPass = "http://100.64.0.9:3111/";
      extraConfig = ''
        rewrite ^/annoy/ws/(.*) /$1 break;
      '';
    };
    locations."/annoy/ws" = {
      proxyWebsockets = true;
      proxyPass = "http://100.64.0.9:3111/";
      extraConfig = ''
        rewrite ^/annoy/ws(.*) /$1 break;
      '';
    };
  };

  services.nginx.virtualHosts."poor.dog" = {
    locations."/".return = "301 https://gaze.systems$request_uri";
  };
}
