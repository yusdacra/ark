{
  pkgs,
  inputs,
  ...
}: let
  GUESTBOOK_WEBSITE_URI = "https://gaze.systems";
  pkg = inputs.blog.packages.${pkgs.system}.guestbook;
  port = 8080;
in {
  users.users.guestbook = {
    isSystemUser = true;
    group = "guestbook";
  };
  users.groups.guestbook = {};

  systemd.services.guestbook = {
    description = "guestbook";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      User = "guestbook";
      ExecStart = "${pkg}/bin/guestbook";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "/var/lib/guestbook";
      Environment = "HOME=/var/lib/guestbook";
      EnvironmentFile = pkgs.writeText "guestbook-env" ''
        GUESTBOOK_WEBSITE_URI="${GUESTBOOK_WEBSITE_URI}"
        PORT=${toString port}
      '';
    };
  };
}
