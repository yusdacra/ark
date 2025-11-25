{
  config,
  nixosConfig,
  pkgs,
  lib,
  tlib,
  ...
}:
let
  l = lib;
in
{
  imports = [
    ../wayland
    ../wlsunset
    ../mako
    ../tofi
  ];

  home.packages = with pkgs; [niri xwayland-satellite brightnessctl swaybg];
  xdg.configFile."niri/config.kdl".text =
    let
      replace = {
        wallpaper = toString ../../mayer/wallpaper.png;
      };
    in
    l.replaceStrings
    (l.map (n: "%%${n}%%") (l.attrNames replace))
    (l.attrValues replace)
    (l.fileContents ./config.kdl);
}
