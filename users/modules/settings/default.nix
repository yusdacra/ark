{
  config,
  lib,
  ...
}: let
  cfg = config.settings;
  inherit
    (lib)
    types
    mkOption
    mkIf
    ;
in {
  options = {
    settings.terminal = {
      name = mkOption {
        type = types.str;
      };
    };
    settings.font = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      name = mkOption {
        type = types.str;
      };
      package = mkOption {
        type = types.package;
      };
      size = mkOption {
        type = types.ints.unsigned;
      };
    };
  };

  config = mkIf cfg.font.enable {
    home.packages = [cfg.font.package];
  };
}
