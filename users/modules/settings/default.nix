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
      binary = l.mkOption {
        type = t.path;
      };
    };
  };

  config = {
    gtk.iconTheme = cfg.iconTheme;
  };
}
