{
  pkgs,
  lib,
  tlib,
  config,
  inputs,
  ...
} @ globalAttrs: let
  l = lib // builtins;

  nixosConfig = globalAttrs.config;
in {
  users.users.patriot = {
    isNormalUser = true;
    createHome = true;
    home = "/home/patriot";
    extraGroups = l.flatten [
      "wheel"
      "adbusers"
      "dialout"
      "video"
      (l.optional nixosConfig.virtualisation.docker.enable "docker")
    ];
    shell = pkgs.zsh;
    hashedPassword = "$6$spzqhAyJfhHy$iHgLBlhjGn1l8PnbjJdWTn1GPvcjMqYNKUzdCe/7IrX6sHNgETSr/Nfpdmq9FCXLhrAfwHOd/q/8SvfeIeNX4/";
  };
  environment = {
    persistence.${config.system.persistDir}.directories = l.flatten [
      (l.optional nixosConfig.programs.steam.enable "/home/patriot/.local/share/Steam")
      "/home/patriot/.cargo"
      "/home/patriot/proj"
      "/home/patriot/games"
    ];
    systemPackages = [pkgs.qt5.qtwayland];
    shells = with pkgs; [bashInteractive zsh];
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    wlr.settings.screencast = {
      output_name = "eDP-1";
      max_fps = 60;
      exec_before = "pkill mako";
      exec_after = "mako";
      chooser_type = "default";
    };
  };
  programs = {
    # this is needed for impermanence
    fuse.userAllowOther = true;
    adb.enable = true;
    steam.enable = true;
    kdeconnect.enable = true;
    # gnome stuffs
    seahorse.enable = true;
  };
  services = {
    # provide location
    geoclue2 = {
      enable = true;
      appConfig.gammastep = {
        isAllowed = true;
        isSystem = false;
      };
    };
    syncthing.folders = {
      notes = {
        enable = true;
        path = "${config.users.users.patriot.home}/notes";
        devices = ["redmi-phone"];
        ignorePerms = true;
      };
    };
  };
  # gnome keyring better fr fr
  security.pam.services.patriot = {
    enableGnomeKeyring = true;
    enableKwallet = false;
  };
  systemd = {
    targets.network-online.enable = false;
    services = {
      systemd-networkd-wait-online.enable = false;
      NetworkManager-wait-online.enable = false;
    };
  };
  home-manager.users.patriot = {
    config,
    pkgs,
    inputs,
    ...
  }: let
    personal = import ../../personal.nix;
    name = personal.name;
    email = personal.emails.primary;
  in {
    imports = let
      modulesToEnable = l.flatten [
        # desktop stuff
        ["firefox" "hyprland" "wezterm" "font" "rofi" "mako" "discord"]
        # cli stuff
        ["zoxide" "zsh" "fzf" "starship" "direnv"]
        # dev stuff
        ["helix" "git" "ssh" "obsidian"]
      ];
    in
      l.flatten [
        ../../modules/persist
        inputs.nixos-persistence.nixosModules.home-manager.impermanence
        (tlib.prefixStrings "${inputs.self}/users/modules/" modulesToEnable)
      ];

    system.persistDir = nixosConfig.system.persistDir;

    home.persistence."${config.system.persistDir}${config.home.homeDirectory}" = let
      mkPaths = pfx: paths: tlib.prefixStrings "${pfx}/" (l.flatten paths);
    in {
      directories =
        l.flatten [
          "Downloads"
          # "smos"
          ".wine"
          # ssh / gpg / keys
          ".ssh"
          ".gnupg"
          "keys"
          # caches / history stuff
          ".directory_history"
          ".cache"
          "notes"
        ]
        ++ mkPaths ".local/share" [
          "direnv"
          "zsh"
          "keyrings"
          "lutris"
          "PolyMC"
        ]
        ++ mkPaths ".config" [
          "lutris"
          "discord"
          "kdeconnect"
        ];
      files = l.flatten [
        ".config/wallpaper"
        (lib.removePrefix "~/" config.programs.ssh.userKnownHostsFile)
      ];
      allowOther = true;
    };

    fonts.fontconfig.enable = l.mkForce true;
    fonts.settings = {
      enable = true;
      name = "Comic Mono";
      size = 13;
      package = pkgs.comic-mono;
    };
    home = {
      homeDirectory = nixosConfig.users.users.patriot.home;
      packages = with pkgs; [
        # Font stuff
        noto-fonts-cjk
        font-awesome
        dejavu_fonts
        # Programs
        bitwarden
        cargo-outdated
        cargo-release
        cargo-udeps
        vulkan-tools
        krita
        cachix
        gnupg
        imv
        mpv
        ffmpeg
        mupdf
        xdg_utils
        rust-analyzer
        # polymc
        cloudflared
        lutris
        protontricks
      ];
    };
    programs = {
      command-not-found.enable =
        nixosConfig.programs.command-not-found.enable;
      git = {
        signing = {
          key = "E1C119F91F4CAE53E8445CAFBB57FCE7E35984F6";
          signByDefault = true;
        };
        userName = name;
        userEmail = email;
      };
      zsh.loginExtra = ''
        if [[ "$(tty)" == "/dev/tty1" ]]; then
          exec Hyprland
        fi
      '';
    };
    services = {
      gpg-agent = let
        defaultCacheTtl = 3600 * 6;
        maxCacheTtl = 3600 * 24;
      in {
        inherit defaultCacheTtl maxCacheTtl;
        enable = true;
        enableSshSupport = true;
        sshKeys = ["8369D9CA26C3EAAAB8302A88CEE6FD14B58AA965"];
        defaultCacheTtlSsh = defaultCacheTtl;
        maxCacheTtlSsh = maxCacheTtl;
        grabKeyboardAndMouse = false;
        pinentryFlavor = "gtk2";
      };
    };
  };
}
