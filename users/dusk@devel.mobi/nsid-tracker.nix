{
  pkgs,
  inputs,
  ...
}:
let
  server = inputs.nsid-tracker.packages.${pkgs.system}.server;
  port = 6432;
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
      Environment = ["PORT=${toString port};"];
    };

    Install.WantedBy = [ "multi-user.target" ];
  };
}
