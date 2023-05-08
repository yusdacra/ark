{config, pkgs, lib, ...}: let
  cfg = config.programs.musikcube;
in {
  options = {
    programs.musikcube = {
      enable = lib.mkEnableOption "whether to enable musikcube";
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
    home.packages = [cfg.package];
    xdg.configFile."musikcube/settings.json".text = builtins.toJSON cfg.settings;
  };
}
