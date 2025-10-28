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

  home-manager.users.mayer =
    {
      config,
      pkgs,
      inputs,
      secrets,
      ...
    }:
    let
      personal = import ../../personal.nix;
      name = personal.name;
      email = personal.emails.primary;
    in
    {
      imports =
        let
          modulesToEnable = l.flatten [
            [
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
              "helix"
              "git"
              "ssh"
            ]
            [
              "zen"
            ]
          ];
        in
        l.flatten [
          (tlib.prefixStrings "${inputs.self}/users/modules/" modulesToEnable)
          ./stylix.nix
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
        ];
      };

      fonts.fontconfig.enable = l.mkForce true;

      settings.iconTheme = {
        name = "Yaru-dark";
        package = pkgs.yaru-theme;
      };

      home.pointerCursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };
      gtk.enable = true;
      gtk.theme.package = pkgs.yaru-theme;
      gtk.theme.name = "Yaru-dark";

      programs.git.includes = [
        {
          contents = {
            gpg.format = "ssh";
            commit.gpgsign = true;
            user = {
              inherit name email;
              signingkey = builtins.readFile ../../secrets/yusdacra.key.pub;
            };
          };
        }
      ];
    };
}
