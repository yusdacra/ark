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
    java = {
      enable = false;
      package = pkgs.adoptopenjdk-jre-bin;
    };
    wireshark.enable = false;
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
        plasma5.enable = false;
        gnome.enable = false;
        xterm.enable = false;
      };
      displayManager = {
        autoLogin = {
          enable = false;
          user = "patriot";
        };
        lightdm.enable = false;
        gdm = {
          enable = false;
          wayland = true;
        };
        sddm.enable = false;
        startx.enable = true;
      };
    };
  };
  systemd.user.services.gnome-session-restart-dbus.serviceConfig = {Slice = "-.slice";};
  systemd = {
    targets = {network-online.enable = false;};
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
    font = "Monoid HalfTight";
    fontSize = 11;
    fontComb = "${font} ${toString fontSize}";
    fontPackage = pkgs.monoid;
    colorSchemeLight = {
      primary = {
        normal = {
          background = "fbf3db";
          foreground = "53676d";
        };
        bright = {
          background = "d5cdb6";
          foreground = "3a4d53";
        };
      };
      normal = {
        black = "ece3cc";
        gray = "5b5b5b";
        red = "d2212d";
        green = "489100";
        yellow = "ad8900";
        blue = "0072d4";
        magenta = "ca4898";
        cyan = "009c8f";
        white = "909995";
      };
      bright = {
        black = "d5cdb6";
        gray = "7b7b7b";
        red = "cc1729";
        green = "428b00";
        yellow = "a78300";
        blue = "006dce";
        magenta = "c44392";
        cyan = "00978a";
        white = "3a4d53";
      };
    };
    colorSchemeDark = let
      normal = {
        black = "252525";
        gray = "5b5b5b";
        red = "ed4a46";
        green = "70b433";
        yellow = "dbb32d";
        blue = "368aeb";
        magenta = "eb6eb7";
        cyan = "3fc5b7";
        white = "777777";
      };
      bright = {
        black = "3b3b3b";
        gray = "7b7b7b";
        red = "ff5e56";
        green = "83c746";
        yellow = "efc541";
        blue = "4f9cfe";
        magenta = "ff81ca";
        cyan = "56d8c9";
        white = "dedede";
      };
    in {
      inherit normal bright;
      primary = {
        normal = {
          background = "181818";
          foreground = "b9b9b9";
        };
        bright = {
          background = bright.black;
          foreground = bright.white;
        };
      };
    };
    colorScheme =
      # if builtins.pathExists ./light then colorSchemeLight else colorSchemeDark;
      colorSchemeDark;
    bgColor = colorScheme.primary.normal.background;
    fgColor = colorScheme.primary.bright.foreground;
    acColor = colorScheme.normal.yellow;
    acColor2 = colorScheme.normal.magenta;
    alacrittyColors = {
      primary = {
        background = "0x${bgColor}";
        foreground = "0x${fgColor}";
      };
      normal = lib.mapAttrs (_: v: "0x${v}") colorScheme.normal;
      bright = lib.mapAttrs (_: v: "0x${v}") colorScheme.bright;
    };
    # sway attrs reused
    focusedWorkspace = {
      background = "#${bgColor}";
      border = "#${acColor}";
      text = "#${acColor}";
    };
    activeWorkspace = {
      background = "#${bgColor}";
      border = "#${colorScheme.primary.bright.background}";
      text = "#${fgColor}";
    };
    inactiveWorkspace = {
      background = "#${bgColor}";
      border = "#${bgColor}";
      text = "#${fgColor}";
    };
    urgentWorkspace = {
      background = "#${bgColor}";
      border = "#${acColor2}";
      text = "#${acColor2}";
    };
    addIndSway = x: {
      background = x.background;
      border = x.border;
      childBorder = x.border;
      text = x.text;
      indicator = "#111111";
      # don't care
    };
    fonts = [fontComb];
    extraEnv = ''
      export SDL_VIDEODRIVER=wayland
      # needs qt5.qtwayland in systemPackages
      export QT_QPA_PLATFORM=wayland
      #export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
      #export QT_QPA_PLATFORMTHEME=qt5ct
      #export QT_PLATFORM_PLUGIN=qt5ct
    '';
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
        fontPackage
        noto-fonts-cjk
        font-awesome
        dejavu_fonts
        (nerdfonts.override {fonts = ["Monoid"];})
        # Programs
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
        (
          lib.hiPrio
          (
            lutris.overrideAttrs
            (
              old: {
                profile = ''
                  ${old.profile or ""}
                  unset VK_ICD_FILENAMES
                  export VK_ICD_FILENAMES=${nixosConfig.environment.variables.VK_ICD_FILENAMES}'';
              }
            )
          )
        )
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
              extraLibraries = pkgs: [pkgs.pipewire];
              extraProfile = ''
                unset VK_ICD_FILENAMES
                export VK_ICD_FILENAMES=${nixosConfig.environment.variables.VK_ICD_FILENAMES}'';
            }
          )
        )
        /*
         (multimc.overrideAttrs (old: {
         src = builtins.fetchGit { url = "https://github.com/AfoninZ/MultiMC5-Cracked.git"; ref = "develop"; rev = "9069e9c9d0b7951c310fdcc8bdc70ebc422a7634"; submodules = true; };
         }))
         */
        standardnotes
      ];
    };
    wayland.windowManager = {
      sway = let
        mkRofiCmd = args: "${config.programs.rofi.package}/bin/rofi ${lib.concatStringsSep " " args} | ${pkgs.sway}/bin/swaymsg --";
      in {
        enable = true;
        extraSessionCommands = extraEnv;
        wrapperFeatures.gtk = true;
        extraConfig = ''
          exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
          output HEADLESS-1 {
            mode 1920x1080
            bg ~/wallpaper.png fill
          }
        '';
        config = {
          fonts = {
            names = [font];
            size = fontSize + 0.0;
          };
          bars = [{command = "${pkgBin "waybar"}";}];
          colors = {
            background = "#${bgColor}";
            focused = addIndSway focusedWorkspace;
            focusedInactive = addIndSway inactiveWorkspace;
            unfocused = addIndSway activeWorkspace;
            urgent = addIndSway urgentWorkspace;
          };
          gaps.smartBorders = "on";
          menu = mkRofiCmd ["-show" "drun"];
          modifier = "Mod4";
          terminal = pkgBin "alacritty";
          keybindings = let
            mod = config.wayland.windowManager.sway.config.modifier;
            cat = pkgs.coreutils + "/bin/cat";
            grim = pkgBin "grim";
            slurp = pkgBin "slurp";
            pactl = pkgs.pulseaudio + "/bin/pactl";
            playerctl = pkgBin "playerctl";
            wf-recorder = pkgBin "wf-recorder";
            wl-copy = pkgs.wl-clipboard + "/bin/wl-copy";
            wl-paste = pkgs.wl-clipboard + "/bin/wl-paste";
            shotFile = config.home.homeDirectory + "/shots/shot_$(date '+%Y_%m_%d_%H_%M')";
          in
            lib.mkOptionDefault
            {
              "${mod}+q" = "kill";
              "${mod}+Shift+e" = "exit";
              "${mod}+Shift+r" = "reload";
              "${mod}+c" = mkRofiCmd ["-show" "calc"];
              # Screenshot and copy it to clipboard
              "Mod1+s" = ''
                exec export SFILE="${shotFile}.png" && ${grim} "$SFILE" && ${cat} "$SFILE" | ${wl-copy} -t image/png
              '';
              # Save selected area as a picture and copy it to clipboard
              "Mod1+Shift+s" = ''
                exec export SFILE="${shotFile}.png" && ${grim} -g "$(${slurp})" "$SFILE" && ${cat} "$SFILE" | ${wl-copy} -t image/png
              '';
              # Record screen
              "Mod1+r" = ''exec ${wf-recorder} -f "${shotFile}.mp4"'';
              # Record an area
              "Mod1+Shift+r" = ''exec ${wf-recorder} -g "$(${slurp})" -f "${shotFile}.mp4"'';
              # Stop recording
              "Mod1+c" = "exec pkill -INT wf-recorder";
              "XF86AudioRaiseVolume" = "exec ${pactl} set-sink-volume 0 +5%";
              "XF86AudioLowerVolume" = "exec ${pactl} set-sink-volume 0 -5%";
              "XF86AudioMute" = "exec ${pactl} set-sink-mute 0 toggle";
              "XF86AudioPlay" = "exec ${playerctl} play-pause";
              "XF86AudioPrev" = "exec ${playerctl} previous";
              "XF86AudioNext" = "exec ${playerctl} next";
              "XF86AudioStop" = "exec ${playerctl} stop";
            };
          input = {
            "*" = {
              xkb_layout = nixosConfig.services.xserver.layout;
              accel_profile = "flat";
            };
          };
          output = {"*" = {bg = config.home.homeDirectory + "/wallpaper.png" + " fill";};};
        };
      };
    };
    programs = {
      alacritty = {
        enable = true;
        settings = {
          shell = {
            program = "${pkgs.tmux}/bin/tmux";
            args = ["attach"];
          };
          font = {
            normal = {family = font;};
            size = fontSize;
          };
          colors = alacrittyColors;
        };
      };
      tmux = {
        enable = true;
        newSession = true;
        secureSocket = true;
        baseIndex = 1;
        escapeTime = 0;
        keyMode = "vi";
        shortcut = "a";
        extraConfig = ''
          set -g default-terminal "alacritty"
          set -ga terminal-overrides ",alacritty:Tc"
          set -g status off
        '';
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
      qutebrowser = {
        enable = false;
        settings = {
          content.javascript.enabled = false;
          colors.webpage.darkmode.enabled = false;
          tabs = {
            show = "multiple";
            tabs_are_windows = true;
          };
        };
        extraConfig = let
          domains = [
            "discord.com"
            "github.com"
            "gitlab.com"
            "nixos.org"
            "protonmail.com"
            "bitwarden.com"
            "duckduckgo.com"
            "youtube.com"
            "docker.com"
          ];
          enableJsForDomain = d: ''
            config.set('content.javascript.enabled', True, 'https://*.${d}')
          '';
        in ''
          ${lib.concatStrings (map enableJsForDomain domains)}
        '';
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
        envExtra = extraEnv;
        loginExtra = ''
          if [ "$(${pkgs.coreutils}/bin/tty)" = "/dev/tty1" ]; then
          exec sway
          fi
        '';
        initExtra = ''
          export TERM=alacritty
          export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

          function tomp4 () {
            ${pkgs.ffmpeg}/bin/ffmpeg -i $1 -c:v libx264 -preset slow -crf 30 -c:a aac -b:a 128k "$1.mp4"
          }

          function topng () {
            ${pkgs.ffmpeg}/bin/ffmpeg -i $1 "$1.png"
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
              ${pkgs.mosh}/bin/mosh root@chat.harmonyapp.io
            '';
          };
      };
      fzf.enable = true;
      rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        cycle = true;
        font = fontComb;
        terminal = pkgBin "alacritty";
        plugins = with pkgs; [
          rofi-calc
          rofi-systemd
          rofi-file-browser
          rofi-power-menu
        ];
        extraConfig = {
          modi = "drun,calc,file-browser-extended,ssh,keys";
        };
      };
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
          "editor.fontFamily" = "'${font}'";
          "debug.console.fontFamily" = "${font}";
          "debug.console.fontSize" = toString fontSize;
          "terminal.integrated.fontSize" = toString fontSize;
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
        enable = true;
        latitude = 36.9;
        longitude = 30.7;
      };
    };
    xdg = {
      enable = true;
      configFile = {
        "helix/themes/mytheme.toml".text = ''
          "attribute" = { fg = "#${colorScheme.bright.yellow}]" }
          "comment" = { fg = "#${colorScheme.normal.gray}", modifiers = ['italic'] }
          "constant" = { fg = "#${colorScheme.normal.blue}" }
          "constant.builtin" = { fg = "#${colorScheme.bright.blue}" }
          "constructor" = { fg = "#${colorScheme.bright.blue}" }
          "escape" = { fg = "#${colorScheme.bright.yellow}" }
          "function" = { fg = "#${colorScheme.bright.blue}" }
          "function.builtin" = { fg = "#${colorScheme.bright.blue}" }
          "function.macro" = { fg = "#${colorScheme.bright.magenta}" }
          "keyword" = { fg = "#${colorScheme.normal.magenta}", modifiers = ['italic'] }
          "keyword.directive" = { fg = "#${colorScheme.normal.magenta}" }
          "label" = { fg = "#${colorScheme.bright.magenta}" }
          "namespace" = { fg = "#${colorScheme.bright.blue}" }
          "number" = { fg = "#${colorScheme.normal.cyan}" }
          "operator" = { fg = "#${colorScheme.bright.magenta}", modifiers = ['italic'] }
          "property" = { fg = "#${colorScheme.normal.red}" }
          "special" = { fg = "#${colorScheme.bright.blue}" }
          "string" = { fg = "#${colorScheme.normal.green}" }
          "type" = { fg = "#${colorScheme.normal.cyan}", modifiers = ['bold'] }
          "type.builtin" = { fg = "#${colorScheme.normal.cyan}", modifiers = ['bold'] }
          "variable" = { fg = "#${colorScheme.bright.blue}", modifiers = ['italic'] }
          "variable.builtin" = { fg = "#${colorScheme.bright.blue}", modifiers = ['italic'] }
          "variable.parameter" = { fg = "#${colorScheme.bright.red}", modifiers = ['italic'] }
          "ui.menu.selected" = { fg = "#${bgColor}", bg = "#${acColor}" }
          "ui.background" = { fg = "#${fgColor}", bg = "#${bgColor}" }
          "ui.help" = { bg = "#${colorScheme.normal.black}" }
          "ui.linenr" = { fg = "#${colorScheme.primary.bright.background}", modifiers = ['bold'] }
          "ui.linenr.selected" = { fg = "#${fgColor}", modifiers = ['bold'] }
          "ui.popup" = { bg = "#${colorScheme.normal.black}" }
          "ui.statusline" = { fg = "#${fgColor}", bg = "#${bgColor}" }
          "ui.statusline.inactive" = { fg = "#${fgColor}", bg = "#${bgColor}" }
          "ui.selection" = { bg = "#${colorScheme.primary.bright.background}" }
          "ui.text" = { fg = "#${fgColor}", bg = "#${bgColor}" }
          "ui.text.focus" = { fg = "#${fgColor}", bg = "#${bgColor}", modifiers = ['bold'] }
          "ui.window" = { bg = "#${bgColor}" }
          "ui.cursor.primary" = { fg = "#${fgColor}", modifiers = ["reversed"] }

          "info" = { fg = "#${colorScheme.normal.blue}", modifiers = ['bold'] }
          "hint" = { fg = "#${colorScheme.bright.green}", modifiers = ['bold'] }
          "warning" = { fg = "#${colorScheme.normal.yellow}", modifiers = ['bold'] }
          "error" = { fg = "#${colorScheme.bright.red}", modifiers = ['bold'] }
        '';
        "helix/config.toml".text = ''
          theme = "mytheme"
          [editor]
          line-number = "relative"
          [lsp]
          display-messages = true
        '';
        "helix/languages.toml".text = ''
          [[language]]
          name = "nix"
          language-server = { command = "${pkgBin "rnix-lsp"}" }
        '';
        "waybar/config".text = let
          swayEnabled = config.wayland.windowManager.sway.enable;
        in
          builtins.toJSON
          {
            layer = "top";
            position = "top";
            modules-left =
              if swayEnabled
              then ["sway/workspaces"]
              else [];
            modules-center =
              if swayEnabled
              then ["sway/window"]
              else [];
            modules-right = ["pulseaudio" "cpu" "memory" "temperature" "clock" "tray"];
            tray = {spacing = 8;};
            cpu = {format = "/cpu {usage}/";};
            memory = {format = "/mem {}/";};
            temperature = {
              hwmon-path = "/sys/class/hwmon/hwmon1/temp2_input";
              format = "/tmp {temperatureC}C/";
            };
            pulseaudio = {
              format = "/vol {volume}/ {format_source}";
              format-bluetooth = "/volb {volume}/ {format_source}";
              format-bluetooth-muted = "/volb/ {format_source}";
              format-muted = "/vol/ {format_source}";
              format-source = "/mic {volume}/";
              format-source-muted = "/mic/";
            };
          };
        "waybar/style.css".text = let
          makeBorder = color: "border-bottom: 3px solid #${color};";
          makeInfo = color: ''
            color: #${color};
            ${makeBorder color}
          '';
          clockColor = colorScheme.bright.magenta;
          cpuColor = colorScheme.bright.green;
          memColor = colorScheme.bright.blue;
          pulseColor = {
            normal = colorScheme.bright.cyan;
            muted = colorScheme.bright.gray;
          };
          tmpColor = {
            normal = colorScheme.bright.yellow;
            critical = colorScheme.bright.red;
          };
        in ''
          * {
              border: none;
              border-radius: 0;
              /* `otf-font-awesome` is required to be installed for icons */
              font-family: ${font};
              font-size: ${toString fontSize}px;
              min-height: 0;
          }

          window#waybar {
              background-color: #${bgColor};
              /* border-bottom: 0px solid rgba(100, 114, 125, 0.5); */
              color: #${fgColor};
              transition-property: background-color;
              transition-duration: .5s;
          }

          #workspaces button {
              padding: 0 5px;
              background-color: transparent;
              color: #${fgColor};
              border-bottom: 3px solid transparent;
          }

          /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
          #workspaces button:hover {
              background: rgba(0, 0, 0, 0.2);
              box-shadow: inherit;
              border-bottom: 3px solid #ffffff;
          }

          #workspaces button.focused {
              border-bottom: 3px solid #${acColor};
          }

          #workspaces button.urgent {
              background-color: #${acColor};
              color: #${bgColor};
          }

          #mode {
              background-color: #64727D;
              border-bottom: 3px solid #ffffff;
          }

          #clock,
          #battery,
          #cpu,
          #memory,
          #temperature,
          #backlight,
          #network,
          #pulseaudio,
          #custom-media,
          #tray,
          #mode,
          #idle_inhibitor,
          #mpd {
              padding: 0 10px;
              margin: 0 4px;
              background-color: transparent;
              ${makeInfo fgColor}
          }

          label:focus {
              color: #000000;
          }

          #clock {
              ${makeInfo clockColor}
          }

          #cpu {
              ${makeInfo cpuColor}
          }

          #memory {
              ${makeInfo memColor}
          }

          #pulseaudio {
              ${makeInfo pulseColor.normal}
          }

          #pulseaudio.muted {
              ${makeInfo pulseColor.muted}
          }

          #temperature {
              ${makeInfo tmpColor.normal}
          }

          #temperature.critical {
              ${makeInfo tmpColor.critical}
          }
        '';
      };
    };
  };
}
