{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.musikcubed;
in {
  options = {
    services.musikcubed = {
      enable = lib.mkEnableOption "whether to enable musikcubed";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.musikcube;
      };
      settings = lib.mkOption {
        type = (pkgs.formats.json {}).type;
        default = builtins.fromJSON (builtins.readFile ./default-config.json);
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.user.services.musikcubed = {
      # Install = {
      #   WantedBy = ["default.target"];
      # };
      Unit = {
        Description = "musikcubed";
        After = "network.target";
      };
      Service = {
        ExecStart = "${cfg.package}/bin/musikcubed --foreground";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
    xdg.configFile."musikcube/plugin_musikcubeserver(wss,http).json".text = builtins.toJSON cfg.settings;
  };
}
