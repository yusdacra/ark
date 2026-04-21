{ config, terra, ... }:
{
  age.secrets.atspool.file = ../../../secrets/atspool.age;
  systemd.user.services.atspool = {
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${terra.atspool}/bin/atspool";
      EnvironmentFile = config.age.secrets.atspool.path;
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "%h/.config/atspool";
    };
  };
}
