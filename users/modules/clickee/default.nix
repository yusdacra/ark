{ terra, ... }:
{
  systemd.user.services.clickee = {
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${terra.clickee}/bin/clickee";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "%h/.config/clickee";
    };
  };
}
