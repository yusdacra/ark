{
  pkgs,
  lib,
  tlib,
  ...
} @ globalAttrs: let
  inherit (lib) mapAttrs' nameValuePair;
  inherit (builtins) readDir fetchGit;

  pkgBin = tlib.pkgBin pkgs;
  nixosConfig = globalAttrs.config;
  useWayland = false;
in {
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
    systemPackages = lib.optional useWayland pkgs.qt5.qtwayland;
    shells = with pkgs; [bashInteractive zsh];
  };
  xdg.portal = {
    enable = true;
    wlr.enable = useWayland;
    gtkUsePortal = false;
    extraPortals = lib.optional useWayland pkgs.xdg-desktop-portal-wlr;
  };
  programs = {
    fuse.userAllowOther = true;
    adb.enable = true;
    steam.enable = true;
    kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
    gnome-disks.enable = false;
    file-roller.enable = false;
    seahorse.enable = true;
  };
  security = {
    pam.services.patriot = {
      enableGnomeKeyring = true;
      enableKwallet = false;
    };
  };
  services = {
    gnome = {
      gnome-keyring.enable = true;
      core-shell.enable = true;
      core-os-services.enable = true;
      chrome-gnome-shell.enable = true;
      at-spi2-core.enable = true;
      gnome-online-accounts.enable = false;
      gnome-online-miners.enable = lib.mkForce false;
      gnome-remote-desktop.enable = false;
      core-utilities.enable = false;
      tracker-miners.enable = false;
      tracker.enable = false;
      gnome-settings-daemon.enable = lib.mkForce false;
      sushi.enable = false;
    };
    xserver = {
      enable = true;
      desktopManager = {
        gnome.enable = true;
        xterm.enable = false;
      };
      displayManager = {
        autoLogin = {
          enable = true;
          user = "patriot";
        };
        gdm = {
          enable = true;
          wayland = useWayland;
        };
        startx.enable = false;
      };
    };
  };
  systemd = {
    targets.network-online.enable = false;
    services = {
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
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
    font = {
      name = "Comic Mono";
      size = 13;
      package = let
        ttf = pkgs.fetchurl {
          url = "https://dtinth.github.io/comic-mono-font/ComicMono.ttf";
          sha256 = "sha256-O8FCXpIqFqvw7HZ+/+TQJoQ5tMDc6YQy4H0V9drVcZY=";
        };
      in
        pkgs.runCommand "comic-mono" {} ''
          mkdir -p $out/share/fonts/truetype
          ln -s ${ttf} $out/share/fonts/truetype
        '';
    };
  in {
    imports = [
      ../modules/direnv
      ../modules/git
      ../modules/starship
      ../modules/helix
      # ../modules/smos
      inputs.nixos-persistence.nixosModules.home-manager.impermanence
    ];

    gtk = {
      enable = true;
      theme = {
        name = "Catppuccin";
        package = pkgs.catppuccin-gtk;
      };
    };

    home.persistence."/persist/home/patriot" = let
      mkPaths = prefix: paths:
        builtins.map (n: "${prefix}/${n}") paths;
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
          "zoxide"
          "direnv"
          "zsh"
          "Steam"
          "backgrounds"
          "keyrings"
          "lutris"
          "PolyMC"
        ]
        ++ mkPaths ".config" [
          "dconf"
          "chromium"
          "gsconnect"
          "lutris"
        ];
      files = [
        ".config/gnome-initial-setup-done"
        (lib.removePrefix "~/" config.programs.ssh.userKnownHostsFile)
      ];
      allowOther = true;
    };

    fonts.fontconfig.enable = lib.mkForce true;
    home = {
      stateVersion = nixosConfig.system.stateVersion;
      homeDirectory = nixosConfig.users.users.patriot.home;
      packages = with pkgs; [
        # Font stuff
        font.package
        noto-fonts-cjk
        font-awesome
        dejavu_fonts
        # Programs
        bitwarden
        wezterm
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
        gnome.gnome-themes-extra
        gnome.gnome-tweaks
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
        // {
          FZF_DEFAULT_OPTS = "--color=bg+:#302D41,bg:#1E1E2E,spinner:#F8BD96,hl:#F28FAD --color=fg:#D9E0EE,header:#F28FAD,info:#DDB6F2,pointer:#F8BD96 --color=marker:#F8BD96,fg+:#F2CDCD,prompt:#DDB6F2,hl+:#F28FAD";
        };
    };
    programs = {
      command-not-found.enable =
        nixosConfig.programs.command-not-found.enable;
      chromium = {
        enable = true;
        package =
          if useWayland
          then pkgs.chromium-wayland
          else pkgs.chromium;
        extensions = [
          # https everywhere
          "gcbommkclmclpchllfjekcdonpmejbdp"
          # ublock
          "cjpalhdlnbpafiamejdnhcphjbkeiagm"
          # bitwarden
          "nngceckbapebfimnlniiiahkandclblb"
          # decentraleyes
          "ldpochfccmkkmhdbclfhpagapcfdljkj"
          # dark theme
          "annfbnbieaamhaimclajlajpijgkdblo"
          # dark reader
          "eimadpbcbfnmbkopoojfekhnkhdbieeh"
          # github refined
          "hlepfoohegkhhmjieoechaddaejaokhf"
          # privacy redirect
          "pmcmeagblkinmogikoikkdjiligflglb"
          # pronoundb
          "nblkbiljcjfemkfjnhoobnojjgjdmknf"
        ];
      };
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
        plugins = let
          fast-syntax-highlighting = let
            name = "fast-syntax-highlighting";
          in {
            inherit name;
            src = pkgs."zsh-${name}".out;
          };
          per-directory-history = {
            name = "per-directory-history";
            src =
              pkgs.fetchFromGitHub
              {
                owner = "jimhester";
                repo = "per-directory-history";
                rev = "d2e291dd6434e340d9be0e15e1f5b94f32771c06";
                hash = "sha256-VHRgrVCqzILqOes8VXGjSgLek38BFs9eijmp0JHtD5Q=";
              };
          };
        in [fast-syntax-highlighting per-directory-history];
        # xdg compliant
        dotDir = ".config/zsh";
        history.path = "${config.home.homeDirectory}/.local/share/zsh/history";
        initExtra = ''
          export TERM=alacritty
          export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

          function tomp4 () {
            ${pkgBin "ffmpeg"} -i $1 -c:v libx264 -preset slow -crf 30 -c:a aac -b:a 128k "$1.mp4"
          }

          function topng () {
            ${pkgBin "ffmpeg"} -i $1 "$1.png"
          }

          bindkey "$terminfo[kRIT5]" forward-word
          bindkey "$terminfo[kLFT5]" backward-word
          zstyle ':completion:*' menu select

          eval "$(zoxide init zsh)"
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
        pinentryFlavor = "gnome3";
      };
    };
    xdg = {
      enable = true;
      configFile = {
        "wezterm/wezterm.lua".text = import ./config/wezterm/cfg.nix {inherit font;};
        "wezterm/colors/catppuccin.lua".source = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/wezterm/65078e846c8751e9b4837a575deb0745f0c0512f/catppuccin.lua";
          sha256 = "sha256:0cm8kjjga9k1fzgb7nqjwd1jdjqjrkkqaxcavfxdkl3mw7qiy1ib";
        };
      };
    };
  };
}
