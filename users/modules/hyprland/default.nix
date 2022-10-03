{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../wayland
    ../swaylock
    ../wlsunset
    ../eww
    ../foot
    ../dunst
    ../rofi
    ./swayidle.nix
    ./config.nix
    inputs.hyprland.homeManagerModules.default
  ];

  home.sessionVariables.GDK_SCALE = "2";

  home.packages = with pkgs; [
    wf-recorder
    xorg.xprop
    inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
    light
    playerctl
    wlogout
    swaybg
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };
}
