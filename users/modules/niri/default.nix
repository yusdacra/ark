{
  config,
  nixosConfig,
  pkgs,
  lib,
  tlib,
  ...
}:
{
  imports = [
    ../wayland
    ../wlsunset
    ../mako
    ../tofi
  ];

  home.packages = with pkgs; [niri xwayland-satellite brightnessctl swaybg];
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
}
