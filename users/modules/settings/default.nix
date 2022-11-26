{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;
  cfg = config.settings;
  fontSettings = {
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
      binary = l.mkOption {
        type = t.path;
      };
    };
    settings.font = {
      regular = fontSettings;
      monospace = fontSettings;
    };
  };

  config = {
    home.packages = [cfg.font.regular.package cfg.font.monospace.package];
    settings.font.regular.fullName = "${cfg.font.regular.name} ${toString cfg.font.regular.size}";
    settings.font.monospace.fullName = "${cfg.font.monospace.name} ${toString cfg.font.monospace.size}";
  };
}
