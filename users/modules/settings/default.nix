{
  config,
  lib,
  ...
}:
let
  l = lib // builtins;
  t = l.types;
  cfg = config.settings;
in
{
  options = {
    settings.enable = l.mkOption {
      type = t.bool;
      default = true;
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
}
