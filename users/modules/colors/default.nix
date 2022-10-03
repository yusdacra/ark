{lib, ...}: let
  l = lib // builtins;
  t = l.types;
in {
  options = {
    colors = {
      theme = l.mkOption {
        type = t.str;
      };
      base = l.mkOption {
        type = t.attrsOf t.str;
      };
      x = l.mkOption {
        type = t.attrsOf t.str;
      };
      xrgba = l.mkOption {
        type = t.attrsOf t.str;
      };
      xargb = l.mkOption {
        type = t.attrsOf t.str;
      };
      rgba = l.mkOption {
        type = t.attrsOf t.str;
      };
    };
  };
}
