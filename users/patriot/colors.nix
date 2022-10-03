{
  lib,
  tlib,
  inputs,
  ...
}: let
  l = lib;
  theme = "catppuccin";
  colors = with tlib.colors; let
    baseColors = inputs.nix-colors.colorSchemes.${theme}.colors;
  in {
    base = baseColors;
    # #RRGGBB
    x = l.mapAttrs (_: x) baseColors;
    # #RRGGBBAA
    xrgba = l.mapAttrs (_: xrgba) baseColors;
    # #AARRGGBB
    xargb = l.mapAttrs (_: xargb) baseColors;
    # rgba(,,,) colors (css)
    rgba = l.mapAttrs (_: rgba) baseColors;
  };
in {
  imports = [../modules/colors];
  config.colors = colors // {inherit theme;};
}
