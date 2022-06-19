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
    systemPackages = [pkgs.qt5.qtwayland];
    shells = with pkgs; [bashInteractive zsh];
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    gtkUsePortal = false;
    extraPortals = with pkgs; [xdg-desktop-portal-wlr];
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
          wayland = true;
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
      # ../modules/smos
      inputs.nixos-persistence.nixosModules.home-manager.impermanence
    ];

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
          "seahorse"
        ]
        ++ mkPaths ".config" [
          "dconf"
          "chromium"
          "gsconnect"
          "seahorse"
        ];
      files = [
        ".config/gnome-initial-setup-done"
        (lib.removePrefix "~/" config.programs.ssh.userKnownHostsFile)
      ];
      allowOther = true;
    };

    fonts.fontconfig.enable = lib.mkForce true;
    home = {
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
        rust-analyzer
        /*
         (multimc.overrideAttrs (old: {
         src = builtins.fetchGit { url = "https://github.com/AfoninZ/MultiMC5-Cracked.git"; ref = "develop"; rev = "9069e9c9d0b7951c310fdcc8bdc70ebc422a7634"; submodules = true; };
         }))
         */
        cloudflared
      ];
      shellAliases =
        nixosConfig.environment.shellAliases
        // {
          harmony-ssh = ''
            ${pkgBin "mosh"} root@chat.harmonyapp.io
          '';
        };
    };
    programs = {
      command-not-found.enable =
        nixosConfig.programs.command-not-found.enable;
      chromium = {
        enable = true;
        package = pkgs.chromium;
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
        history.path = ".local/share/zsh/history";
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
        "helix/themes/mytheme.toml".text = import ./config/helix/mytheme.nix {};
        "helix/config.toml".text = import ./config/helix/cfg.nix {};
        "helix/languages.toml".text = import ./config/helix/languages.nix {inherit pkgBin;};
      };
    };
  };
}
