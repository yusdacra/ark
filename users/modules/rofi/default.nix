{ pkgs, ... }:
{
  stylix.targets.rofi.enable = true;
  programs.rofi = {
    enable = true;
    package = pkgs.rofi.overrideAttrs (old: rec {
      buildInputs = builtins.filter (x: x.pname != "gdk-pixbuf") old.buildInputs;
    });
  };
}
