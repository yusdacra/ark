{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    config.wayland.windowManager.hyprland.package
    config.programs.eww.package
    bc
    bluez
    coreutils
    findutils
    gawk
    gnused
    jq
    light
    networkmanager
    playerctl
    procps
    pulseaudio
    ripgrep
    socat
    upower
    wget
    wireplumber
  ];

  programs.eww = {
    enable = true;
    package = inputs.eww.packages.${pkgs.system}.eww-wayland;
    configDir = ./.;
  };
}
