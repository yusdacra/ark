{
  pkgs,
  terra,
  ...
}:
let
  server = terra.nsid-tracker-server;
in
{
  systemd.user.services.nsid-tracker = {
    Unit = {
      Description = "nsid-tracker";
      After = [ "network.target" ];
    };

    Service = {
      ExecStartPre="${pkgs.coreutils-full}/bin/mkdir -p %D/nsid-tracker";
      ExecStart = "${pkgs.dash}/bin/dash -c 'cd %D/nsid-tracker && ${server}/bin/server'";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "multi-user.target" ];
  };
}
