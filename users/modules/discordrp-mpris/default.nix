{inputs, pkgs, ...}: {
  systemd.user.services.discordrp-mpris = {
    Install = {
      WantedBy = ["default.target"];
    };
    Unit = {
      Description = "discordrp-mpris";
    };
    Service = {
      ExecStart = "${inputs.discordrp-mpris.packages.${pkgs.system}.default}/bin/discordrp-mpris";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
  xdg.configFile."discordrp-mpris/config.toml".source = ./config.toml;
}
