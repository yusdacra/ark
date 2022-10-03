{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;
  cfg = config.settings;
in {
  options = {
    settings.iconTheme = {
      name = l.mkOption {
        type = t.str;
      };
      package = l.mkOption {
        type = t.package;
      };
    };
    settings.terminal = {
      name = l.mkOption {
        type = t.str;
      };
    };
    settings.font = {
      enable = l.mkOption {
        type = t.bool;
        default = false;
      };
      name = l.mkOption {
        type = t.str;
      };
      package = l.mkOption {
        type = t.package;
      };
      size = l.mkOption {
        type = t.ints.unsigned;
      };
      fullName = l.mkOption {
        type = t.str;
        readOnly = true;
      };
    };
  };

  config = l.mkIf cfg.font.enable {
    home.packages = [cfg.font.package];
    settings.font.fullName = "${cfg.font.name} ${toString cfg.font.size}";
  };
}
