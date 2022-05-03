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
    gtkUsePortal = true;
    extraPortals = with pkgs; [xdg-desktop-portal xdg-desktop-portal-wlr];
  };
  programs = {
    adb.enable = true;
    steam.enable = true;
  };
  security = {
    pam.services.patriot = {
      enableGnomeKeyring = true;
      enableKwallet = false;
    };
    sudo.extraRules = [
      {
        users = ["patriot"];
        commands = [
          {
            command = "${pkgs.profile-sync-daemon}/bin/psd-overlay-helper";
            options = ["SETENV" "NOPASSWD"];
          }
        ];
      }
    ];
  };
  services = {
    psd.enable = true;
    gnome = {
      gnome-keyring.enable = true;
      core-utilities.enable = false;
      tracker-miners.enable = false;
      tracker.enable = false;
    };
    xserver = {
      enable = true;
      desktopManager = {
        gnome.enable = true;
        xterm.enable = false;
      };
      displayManager = {
        autoLogin = {
          enable = false;
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
      systemd-networkd-wait-online.enable = false;
      NetworkManager-wait-online.enable = false;
    };
  };
  home-manager.users.patriot = {
    config,
    pkgs,
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
    ];
    fonts.fontconfig.enable = lib.mkForce true;
    home = {
      homeDirectory = nixosConfig.users.users.patriot.home;
      packages = with pkgs; [
        # Font stuff
        font.package
        noto-fonts-cjk
        font-awesome
        dejavu_fonts
        (nerdfonts.override {fonts = ["Monoid"];})
        # Programs
        wezterm
        cargo-outdated
        cargo-release
        cargo-udeps
        vulkan-tools
        krita
        gnome3.seahorse
        cachix
        appimage-run
        pfetch
        gnupg
        imv
        mpv
        youtube-dl
        ffmpeg
        mupdf
        transmission-qt
        lutris
        xdg_utils
        tagref
        hydrus
        papirus-icon-theme
        wl-clipboard
        rust-analyzer
        (
          lib.hiPrio
          (
            steam.override
            {
              extraLibraries = pkgs: with pkgs; [mimalloc pipewire vulkan-loader wayland wayland-protocols];
            }
          )
        )
        /*
         (multimc.overrideAttrs (old: {
         src = builtins.fetchGit { url = "https://github.com/AfoninZ/MultiMC5-Cracked.git"; ref = "develop"; rev = "9069e9c9d0b7951c310fdcc8bdc70ebc422a7634"; submodules = true; };
         }))
         */
        standardnotes
        #discord-system-electron
        gh
        cloudflared
        ripcord
      ];
    };
    programs = {
      firefox = {
        enable = true;
      };
      chromium = {
        enable = true;
        package = pkgs.chromium;
        extensions = [
          "gcbommkclmclpchllfjekcdonpmejbdp"
          # https everywhere
          "cjpalhdlnbpafiamejdnhcphjbkeiagm"
          # ublock
          "nngceckbapebfimnlniiiahkandclblb"
          # bitwarden
          "ldpochfccmkkmhdbclfhpagapcfdljkj"
          # decentraleyes
          "annfbnbieaamhaimclajlajpijgkdblo"
          # dark theme
          "eimadpbcbfnmbkopoojfekhnkhdbieeh"
          # dark reader
          "hlepfoohegkhhmjieoechaddaejaokhf"
          # github refined
          "pmcmeagblkinmogikoikkdjiligflglb"
          # privacy redirect
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
        shellAliases =
          nixosConfig.environment.shellAliases
          // {
            harmony-ssh = ''
              ${pkgBin "mosh"} root@chat.harmonyapp.io
            '';
          };
      };
      fzf.enable = true;
      vscode = {
        enable = true;
        package = pkgs.vscode;
        extensions = let
          mkExt = n: v: p: s: {
            name = n;
            version = v;
            publisher = p;
            sha256 = s;
          };
        in
          (
            pkgs.vscode-utils.extensionsFromVscodeMarketplace
            [
              # Rust
              (mkExt "rust-analyzer" "0.3.968" "matklad" "sha256-wuNdmUYburGjgri8gFJl1FSryJbz1aXjJy4NQ+/Wbk4=")
              (mkExt "even-better-toml" "0.14.2" "tamasfe" "sha256-lE2t+KUfClD/xjpvexTJlEr7Kufo+22DUM9Ju4Tisp0=")
              (mkExt "crates" "0.5.10" "serayuzgur" "sha256-bY/dphiEPPgTg1zMjvxx4b0Ska2XggRucnZxtbppcLU=")
              # Nix
              (
                mkExt "nix-env-selector" "1.0.7" "arrterian" "sha256-DnaIXJ27bcpOrIp1hm7DcrlIzGSjo4RTJ9fD72ukKlc="
              )
              # Go
              (mkExt "Go" "0.32.0" "golang" "sha256-OsKeZrG157l1HUCDvymJ3ovLxlEEJf7RBe2hXOutdyg=")
              # Flutter and dart
              (mkExt "flutter" "3.37.20220301" "Dart-Code" "sha256-PS24pbqKNZ/myNcTqgjosG0Pq58yMoATKDgy3k23JlE=")
              (mkExt "dart-code" "3.37.20220303" "Dart-Code" "sha256-hS+V4kLe+eGIqj/1mZdgbhxWWxqSr2ZUsc2V0HI6tN8=")
              # protobuf
              (mkExt "vscode-proto3" "0.5.5" "zxh404" "sha256-Em+w3FyJLXrpVAe9N7zsHRoMcpvl+psmG1new7nA8iE=")
              (mkExt "vscode-buf" "0.4.0" "bufbuild" "sha256-VM6LYYak1rB4AdpVYfKpOfizGaFI/R+iUsf6UT50vdw=")
              # git
              (mkExt "gitlens" "12.0.2" "eamodio" "sha256-et2uam4hOQkxxT+r0fwZhpWGjHk45NAOriFA/43ngpo=")
              # Customization
              (mkExt "material-icon-theme" "4.14.1" "PKief" "sha256-OHXi0EfeyKMeFiMU5yg0aDoWds4ED0lb+l6T12XZ3LQ=")
              (mkExt "horizon-theme-vscode" "1.0.0" "alexandernanberg" "sha256-M7SmOYPkAVi5jQLynZqTjmFo9UcQ6W4dU4euP6ua9Z8=")
            ]
          )
          ++ (
            with pkgs.vscode-extensions; [
              a5huynh.vscode-ron
              /*
               vadimcn.vscode-lldb
               */
              jnoortheen.nix-ide
            ]
          );
        userSettings = {
          "workbench.iconTheme" = "material-icon-theme";
          "workbench.colorTheme" = "Horizon Bold";
          "rust-analyzer.cargo.loadOutDirsFromCheck" = true;
          "rust-analyzer.procMacro.enable" = true;
          "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
          "rust-analyzer.updates.channel" = "nightly";
          "editor.fontFamily" = "'${font.name}'";
          "debug.console.fontFamily" = "${font.name}";
          "debug.console.fontSize" = toString font.size;
          "terminal.integrated.fontSize" = toString font.size;
          "go.useLanguageServer" = true;
          "rust-analyzer.checkOnSave.command" = "clippy";
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = pkgBin "rnix-lsp";
          "editor.bracketPairColorization.enabled" = true;
          "editor.semanticHighlighting.enabled" = true;
          "remote.SSH.defaultExtensions" = [
            "gitpod.gitpod-remote-ssh"
          ];
        };
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
        pinentryFlavor = "qt";
      };
      gammastep = {
        enable = false;
        latitude = 36.9;
        longitude = 30.7;
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
