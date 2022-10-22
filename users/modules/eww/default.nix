{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  dependencies = with pkgs; [
    config.wayland.windowManager.hyprland.package
    config.programs.eww.package
    # notifs
    dunst
    # utils
    coreutils
    findutils
    gawk
    gnused
    jq
    bash
    bc
    ripgrep
    socat
    procps
    util-linux
    wget
    # brightness
    light
    # network
    networkmanager
    config.programs.rofi-nm.package
    # volume
    wireplumber
    playerctl
    pulseaudio
    # session management
    wlogout
    # bluetooth
    blueberry
    bluez
    # misc
    dbus
    udev
    upower
  ];
in {
  imports = [../rofi-nm];

  programs.eww = {
    enable = true;
    package = inputs.eww.packages.${pkgs.system}.eww-wayland;
    # remove nix files
    configDir = lib.cleanSourceWith {
      filter = name: _type: let
        baseName = baseNameOf (toString name);
      in
        !(lib.hasSuffix ".nix" baseName);
      src = lib.cleanSource ./.;
    };
  };

  home.packages = with pkgs; [
    material-icons
    material-design-icons
    (nerdfonts.override {fonts = ["Hack"];})
  ];

  systemd.user.services.eww = {
    Unit = {
      Description = "Eww Daemon";
      # not yet implemented
      # PartOf = ["tray.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}";
      ExecStart = "${config.programs.eww.package}/bin/eww daemon --no-daemonize";
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
