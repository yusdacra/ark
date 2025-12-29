{
  pkgs,
  lib,
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
    ../clipman
  ];

  home.packages = with pkgs; [file libnotify clipman niri xwayland-satellite brightnessctl swaybg];
  xdg.configFile."niri/config.kdl".text =
    let
      replace = {
        wallpaper = toString ../../mayer/wallpaper.png;
        clipboard-upload = toString ./uploader.nu;
        clipboard-select = toString ./clipboard.nu;
      };
    in
    l.replaceStrings
    (l.map (n: "%%${n}%%") (l.attrNames replace))
    (l.attrValues replace)
    (l.fileContents ./config.kdl);
}
