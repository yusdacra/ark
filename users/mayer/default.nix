{
  pkgs,
  lib,
  tlib,
  config,
  ...
}@globalAttrs:
let
  l = lib // builtins;

  nixosConfig = globalAttrs.config;
in
{
  imports = [ ./stylix.nix ];

  users.users.mayer = {
    isNormalUser = true;
    createHome = true;
    home = "/home/mayer";
    extraGroups = l.flatten [
      "wheel"
      "adbusers"
      "dialout"
      "video"
    ];
    shell = pkgs.nushell;
    hashedPassword = "$6$spzqhAyJfhHy$iHgLBlhjGn1l8PnbjJdWTn1GPvcjMqYNKUzdCe/7IrX6sHNgETSr/Nfpdmq9FCXLhrAfwHOd/q/8SvfeIeNX4/";
  };

  environment.shells = with pkgs; [
    bashInteractive
    nushell
  ];
  programs = {
    steam.enable = true;
    gamescope.enable = true;
    gamemode.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
    sway.enable = true;
  };
  systemd = {
    targets.network-online.enable = false;
    services = {
      systemd-networkd-wait-online.enable = false;
      NetworkManager-wait-online.enable = false;
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;

  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }
  ];

  home-manager.users.mayer =
    {
      pkgs,
      inputs,
      ...
    }:
    {
      imports =
        let
          modulesToEnable = l.flatten [
            [
              "settings"
              "sway"
              "wayland"
              "foot"
            ]
            # cli stuff
            [
              "zoxide"
              "direnv"
              "nushell"
            ]
            # dev stuff
            [
              "zed"
              "helix"
              "git"
              "ssh"
            ]
            [
              "zen"
              "discord"
            ]
          ];
        in
        l.flatten [
          (tlib.prefixStrings "${inputs.self}/users/modules/" modulesToEnable)
        ];

      home = {
        homeDirectory = nixosConfig.users.users.mayer.home;
        packages = with pkgs; [
          # Font stuff
          noto-fonts-cjk-sans
          font-awesome
          dejavu_fonts
          # Programs
          imv
          mpv
          ffmpeg
          mupdf
          xdg-utils
          transmission_4-gtk
          prismlauncher
          gearlever
          signal-desktop
          bs-manager
        ];
      };

      fonts.fontconfig.enable = l.mkForce true;
    };
}
