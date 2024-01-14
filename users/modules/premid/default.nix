{pkgs, ...}: {
  systemd.user.services.premid = {
    Install = {
      WantedBy = ["default.target"];
    };
    Unit = {
      Description = "premid";
    };
    Service = {
      ExecStart = "${pkgs.premid}/bin/premid";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
