{pkgs, ...}: {
  systemd.user.services.arrpc = {
    Install = {
      WantedBy = ["default.target"];
    };
    Unit = {
      Description = "arrpc";
    };
    Service = {
      ExecStart = "${pkgs.arrpc}/bin/arrpc";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
