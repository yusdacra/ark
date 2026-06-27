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

  home.packages = with pkgs; [file libnotify clipman niri xwayland-satellite brightnessctl swaybg slurp jq mpvpaper];
  xdg.configFile."niri/config.kdl".text =
    let
      replace = {
        wallpaper = toString ../../mayer/wallpaper.webp;
        clipboard-upload = toString ./uploader.nu;
        clipboard-select = toString ./clipboard.nu;
        gsr-replay-save = toString ../gsr/save-replay.sh;
        gsr-record-screen = toString ../gsr/record-screen.sh;
        gsr-record-area = toString ../gsr/record-area.sh;
      };
    in
    l.replaceStrings
    (l.map (n: "%%${n}%%") (l.attrNames replace))
    (l.attrValues replace)
    (l.fileContents ./config.kdl);
}
