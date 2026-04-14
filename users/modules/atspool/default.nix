{ terra, ... }:
{
  systemd.user.services.atspool = {
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${terra.atspool}/bin/atspool";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "%h/.config/atspool";
    };
  };
}
