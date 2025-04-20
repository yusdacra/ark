{
  config,
  pkgs,
  inputs,
  ...
}: let
  PUBLIC_BASE_URL = "https://gaze.systems";
  pkg = inputs.blog.packages.${pkgs.system}.default.overrideAttrs (old: {
    inherit PUBLIC_BASE_URL;
  });
  port = 3003;
in {
  users.users.website = {
    isSystemUser = true;
    group = "website";
  };
  users.groups.website = {};

  systemd.services.website = {
    description = "website";
    wantedBy = ["multi-user.target"];
    after = ["network.target" "guestbook.service"];
    environment = {
      HOME = "/var/lib/website";
      ORIGIN = PUBLIC_BASE_URL;
      PORT = toString port;
      GUESTBOOK_BASE_URL = "http://localhost:8080";
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

  services.nginx.virtualHosts."gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString port}";
    };
  };
}
