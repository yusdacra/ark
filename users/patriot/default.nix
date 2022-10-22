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
      (l.optional nixosConfig.networking.networkmanager.enable "networkmanager")
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
      "/home/patriot/.var"
    ];
    systemPackages = with pkgs; [qt5.qtwayland];
    shells = with pkgs; [bashInteractive zsh];
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    wlr.settings.screencast = {
      output_name = "eDP-1";
      max_fps = 60;
      chooser_type = "default";
    };
  };
  programs = {
    # this is needed for impermanence
    fuse.userAllowOther = true;
    adb.enable = true;
    steam.enable = true;
    # gnome stuffs
    seahorse.enable = true;
    dconf.enable = true;
    weylus.users = ["patriot"];
  };
  services = {
    syncthing.folders = {
      notes = {
        enable = true;
        path = "${config.users.users.patriot.home}/notes";
        devices = ["redmi-phone"];
        ignorePerms = true;
      };
    };
    gnome.gnome-keyring.enable = true;
  };
  # gnome keyring better fr fr
  security.pam.services.patriot = {
    enableGnomeKeyring = true;
    enableKwallet = false;
  };
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
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
    secrets,
    ...
  }: let
    personal = import ../../personal.nix;
    name = personal.name;
    email = personal.emails.primary;
  in {
    imports = let
      modulesToEnable = l.flatten [
        # wm
        ["hyprland" "foot"]
        # desktop stuff
        ["firefox" "discord"]
        # cli stuff
        ["zoxide" "zsh" "fzf" "starship" "direnv"]
        # dev stuff
        ["helix" "git" "ssh" "obsidian"]
      ];
    in
      l.flatten [
        ./colors.nix
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
          "Terraria"
        ]
        ++ mkPaths ".config" [
          "lutris"
        ];
      files = l.flatten [
        ".config/wallpaper"
        ".config/wallpaper.mp4"
        (lib.removePrefix "~/" config.programs.ssh.userKnownHostsFile)
      ];
      allowOther = true;
    };

    fonts.fontconfig.enable = l.mkForce true;
    settings.font.regular = {
      name = "Comic Relief";
      size = 13;
      package = pkgs.comic-relief;
    };
    settings.font.monospace = {
      name = "Comic Mono";
      size = 13;
      package = pkgs.comic-mono;
    };

    settings.iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    home.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;

      font = {
        inherit (config.settings.font.regular) name package;
      };

      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

      iconTheme = config.settings.iconTheme;

      theme = {
        name = "Catppuccin-Orange-Dark-Compact";
        package = pkgs.catppuccin-gtk.override {size = "compact";};
      };
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
        xdg-utils
        rust-analyzer
        cloudflared
        lutris
        protontricks
        # fractal-next
        (
          writeShellScriptBin "gh" ''
            GH_TOKEN=${secrets.githubToken} ${gh}/bin/gh $@
          ''
        )
        obs-studio
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
        pinentryFlavor = "gnome3";
      };
    };
  };
}
