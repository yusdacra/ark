{
  pkgs,
  lib,
  tlib,
  config,
  ...
} @ globalAttrs: let
  l = lib // builtins;

  nixosConfig = globalAttrs.config;
in {
  imports = [./stylix.nix];

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
      # because steam will be fucked otherwise
      (l.optional nixosConfig.programs.steam.enable "/home/patriot/.local/share/Steam")
      # because cargo doesnt work otherwise
      "/home/patriot/.cargo"
      # same thing since i work with cargo and other shit
      "/home/patriot/proj"
      # same thing as steam
      "/home/patriot/games"
      # flatpak stuff
      "/home/patriot/.var"
      # libvirt stuff, dont think fuse mount would work here
      "/home/patriot/.config/libvirt"
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
    # cuz nixos complains
    zsh.enable = true;
    # this is needed for impermanence
    fuse.userAllowOther = true;
    adb.enable = true;
    steam.enable = true;
    # gnome stuffs
    seahorse.enable = true;
    dconf.enable = true;
    weylus.users = ["patriot"];
    java = {
      enable = true;
      package = pkgs.jre8;
    };
  };
  services = {
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
        # ["hyprland" "foot"]
        ["sway" "foot"]
        # desktop stuff
        ["wayland"]
        ["chromium"]
        # cli stuff
        ["zoxide" "zsh" "fzf" "starship" "direnv"]
        # dev stuff
        ["helix" "code" "git" "ssh"]
        ["lollypop"]
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
          ".wine"
          # ssh / gpg / keys
          ".ssh"
          ".gnupg"
          "keys"
          # caches / history stuff
          ".directory_history"
          ".cache"
        ]
        ++ mkPaths ".local/share" [
          "direnv"
          "zsh"
          "keyrings"
          # "lutris"
          "Terraria"
          "PrismLauncher"
        ]
        ++ mkPaths ".config" [
          # "lutris"
          "dconf"
        ];
      files = l.flatten [
        ".config/gnome-initial-setup-done"
        (lib.removePrefix "~/" config.programs.ssh.userKnownHostsFile)
      ];
      allowOther = true;
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

    home = {
      homeDirectory = nixosConfig.users.users.patriot.home;
      packages = with pkgs; [
        # Font stuff
        noto-fonts-cjk
        font-awesome
        dejavu_fonts
        # Programs
        inputs.blender-bin.packages.x86_64-linux.default
        krita
        gnupg
        imv
        mpv
        ffmpeg
        mupdf
        xdg-utils
        # lutris
        protontricks
        # fractal-next
        # obs-studio
        libreoffice-fresh
        helvum
        nix-output-monitor
        # prismlauncher
        godot_4
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
