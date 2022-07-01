{
  lib,
  config,
  ...
}: let
  cfg = config.fonts.settings;
in
  with lib; {
    options.fonts.settings = {
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

    config = mkIf cfg.enable {
      home.packages = [cfg.package];
    };
  }
