{
  pkgs,
  lib,
  tlib,
  config,
  inputs,
  ...
} @ globalAttrs: let
  inherit (lib) mapAttrs' nameValuePair;
  inherit (builtins) readDir fetchGit;
  l = lib // builtins;

  pkgBin = tlib.pkgBin pkgs;
  nixosConfig = globalAttrs.config;
in {
  imports = [inputs.hyprland.nixosModules.default];

  users.users.patriot = {
    isNormalUser = true;
    createHome = true;
    home = "/home/patriot";
    extraGroups = [
      "wheel"
      "adbusers"
      "dialout"
    ];
    shell = pkgs.zsh;
    hashedPassword = "$6$spzqhAyJfhHy$iHgLBlhjGn1l8PnbjJdWTn1GPvcjMqYNKUzdCe/7IrX6sHNgETSr/Nfpdmq9FCXLhrAfwHOd/q/8SvfeIeNX4/";
  };
  environment = {
    systemPackages = [pkgs.qt5.qtwayland];
    shells = with pkgs; [bashInteractive zsh];
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    gtkUsePortal = true;
    extraPortals = with pkgs; [xdg-desktop-portal-gtk xdg-desktop-portal-wlr];
  };
  programs = {
    # this is needed for impermanence
    fuse.userAllowOther = true;
    adb.enable = true;
    steam.enable = true;
    # gnome stuffs
    seahorse.enable = true;
    hyprland.enable = true;
    hyprland.extraPackages = [];
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
    imports = [
      ../modules/direnv
      ../modules/git
      ../modules/starship
      ../modules/helix
      ../modules/zoxide
      ../modules/wezterm
      ../modules/hyprland
      ../modules/rofi
      ../modules/mako
      ../modules/font
      ../modules/firefox
      ../../modules/persist
      # ../modules/smos
      inputs.nixos-persistence.nixosModules.home-manager.impermanence
    ];

    system.persistDir = nixosConfig.system.persistDir;

    home.persistence."${config.system.persistDir}${config.home.homeDirectory}" = let
      mkPaths = prefix: paths:
        builtins.map (n: "${prefix}/${n}") (l.flatten paths);
    in {
      directories =
        [
          "Downloads"
          "proj"
          # "smos"
          ".steam"
          ".wine"
          # ssh / gpg / keys
          ".ssh"
          ".gnupg"
          "keys"
          # caches / history stuff
          ".directory_history"
          ".cargo"
          ".cache"
        ]
        ++ mkPaths ".local/share" [
          "direnv"
          "zsh"
          "Steam"
          "keyrings"
          "lutris"
          "PolyMC"
        ]
        ++ mkPaths ".config" [
          "lutris"
          "discord"
        ];
      files = l.flatten [
        ".config/wallpaper"
        (lib.removePrefix "~/" config.programs.ssh.userKnownHostsFile)
      ];
      allowOther = true;
    };

    fonts.fontconfig.enable = lib.mkForce true;
    fonts.settings = {
      enable = true;
      name = "Comic Mono";
      size = 13;
      package = let
        ttf = pkgs.fetchurl {
          url = "https://dtinth.github.io/comic-mono-font/ComicMono.ttf";
          sha256 = "sha256-O8FCXpIqFqvw7HZ+/+TQJoQ5tMDc6YQy4H0V9drVcZY=";
        };
      in
        pkgs.runCommandNoCC "comic-mono" {} ''
          mkdir -p $out/share/fonts/truetype
          ln -s ${ttf} $out/share/fonts/truetype
        '';
    };
    home = {
      stateVersion = nixosConfig.system.stateVersion;
      homeDirectory = nixosConfig.users.users.patriot.home;
      packages = with pkgs;
        l.flatten [
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
          wl-clipboard
          xclip
          rust-analyzer
          # polymc
          cloudflared
          lutris
          (pkgs.callPackage pkgs.discord.override {withOpenASAR = true;})
        ];
      shellAliases =
        nixosConfig.environment.shellAliases
        // {
          harmony-ssh = ''
            ${pkgBin "mosh"} root@chat.harmonyapp.io
          '';
        };
      sessionVariables =
        nixosConfig.environment.sessionVariables
        // l.optionalAttrs config.programs.fzf.enable {
          FZF_DEFAULT_OPTS = "--color=spinner:#F8BD96,hl:#F28FAD --color=fg:#D9E0EE,header:#F28FAD,info:#DDB6F2,pointer:#F8BD96 --color=marker:#F8BD96,fg+:#F2CDCD,prompt:#DDB6F2,hl+:#F28FAD";
        };
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
      ssh = {
        enable = true;
        compression = true;
        hashKnownHosts = true;
        userKnownHostsFile = "~/.local/share/ssh/known-hosts";
        # Only needed for darcs hub
        # extraConfig = ''
        #   Host hub.darcs.net
        #      ControlMaster no
        #      ForwardAgent no
        #      ForwardX11 no
        #      Ciphers +aes256-cbc
        #      MACs +hmac-sha1
        # '';
      };
      zsh = {
        enable = true;
        autocd = true;
        enableVteIntegration = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        plugins = [
          {
            name = "per-directory-history";
            src = pkgs.fetchFromGitHub {
              owner = "jimhester";
              repo = "per-directory-history";
              rev = "d2e291dd6434e340d9be0e15e1f5b94f32771c06";
              hash = "sha256-VHRgrVCqzILqOes8VXGjSgLek38BFs9eijmp0JHtD5Q=";
            };
          }
        ];
        # xdg compliant
        dotDir = ".config/zsh";
        history.path = "${config.home.homeDirectory}/.local/share/zsh/history";
        initExtra = ''
          export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

          function tomp4 () {
            ${pkgBin "ffmpeg"} -i $1 -c:v libx264 -preset slow -crf 30 -c:a aac -b:a 128k "$1.mp4"
          }

          function topng () {
            ${pkgBin "ffmpeg"} -i $1 "$1.png"
          }

          # fix some key stuff
          bindkey "$terminfo[kRIT5]" forward-word
          bindkey "$terminfo[kLFT5]" backward-word
          # makes completions pog
          zstyle ':completion:*' menu select
        '';
        loginExtra = ''
          if [[ "$(tty)" == "/dev/tty1" ]]; then
            exec Hyprland
          fi
        '';
      };
      fzf.enable = true;
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
