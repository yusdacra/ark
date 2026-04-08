{
  pkgs,
  lib,
  tlib,
  terra,
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
      "input"
    ];
    shell = pkgs.nushell;
    hashedPassword = "$6$spzqhAyJfhHy$iHgLBlhjGn1l8PnbjJdWTn1GPvcjMqYNKUzdCe/7IrX6sHNgETSr/Nfpdmq9FCXLhrAfwHOd/q/8SvfeIeNX4/";
  };

  environment.shells = with pkgs; [
    bashInteractive
    nushell
  ];
  services.flatpak.enable = true;
  programs = {
    droidcam.enable = true;
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs': with pkgs'; [
          vulkan-loader
          wayland
          wayland-protocols
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib # Provides libstdc++.so.6
          libkrb5
          keyutils
        ];
      };
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    gamemode.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
    niri.enable = true;
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

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = true;
  };

  services.joycond.enable = true;
  services.udev.packages = [pkgs.libimobiledevice];

  home-manager.users.mayer =
    {
      config,
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
              "niri"
              "gsr"
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
              # "zen"
              "discord"
              "clickee"
              "arrpc"
            ]
          ];
        in
        l.flatten [
          (tlib.prefixStrings "${inputs.self}/users/modules/" modulesToEnable)
          ../modules/discord/service.nix
          ../modules/discord/default.nix
          "${inputs.agenix}/modules/age-home.nix"
        ];

      home = {
        homeDirectory = nixosConfig.users.users.mayer.home;
        packages = (with pkgs; [
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
          (prismlauncher.override {
            additionalLibs = with pkgs; [libXtst libxkbcommon libXt];
          })
          xivlauncher
          lutris
          signal-desktop
          bs-manager
          cemu
          tor-browser
          feishin
          # these are for gitnexus
          nodejs
          gcc
          gnumake
          python3
          gh
          # sidelaoding
        ]) ++ [
          terra.helium
          terra.antigravity
          terra.pi-coding-agent
          terra.iloader
          terra.lmstudio
          # terra.gitnexus
          # (terra.pds-upload.override {
          #   secretsFile = config.age.secrets.atfileCfg.path;
          # })
        ];
      };

      age.secrets.atfileCfg = {
        file = ../../secrets/atfileCfg.age;
        mode = "600";
      };

      fonts.fontconfig.enable = l.mkForce true;

      programs.ssh.extraConfig = ''
      Host nixos-shell
        Hostname localhost
        Port 2222
        User git
        IdentityFile ~/.ssh/tangled-dev
      '';
    };
}
