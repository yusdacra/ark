{ config, lib, pkgs, util, ... }:
let
  inherit (lib) mapAttrs' nameValuePair;
  inherit (builtins) readDir;
  inherit (util) pkgBin;

  nixosConfig = config;

  name = "Yusuf Bera Ertan";
  email = "y.bera003.06@protonmail.com";

  font = "Iosevka";
  fontSize = 10;
  fontComb = "${font} ${toString fontSize}";
  fontPackage = pkgs.iosevka;

  kideSrc = builtins.fetchGit {
    url = "https://gitlab.com/yusdacra/kide.git";
    rev = "778d68df0cfcb96d6113bfe6a59e5dfc71ee7d82";
    submodules = true;
  };
  kideFiles =
    mapAttrs' (n: _: nameValuePair "kak/${n}" { source = "${kideSrc}/${n}"; })
      (readDir kideSrc);
  kideDeps = with pkgs; [
    fzf
    bat
    ripgrep
    universal-ctags
    kak-lsp
    wl-clipboard
    xclip
    shellcheck
    perl
    socat
    gdb
    kcr
    jq
    file
  ];

  chromiumWayland = pkgs.writeScriptBin "chromium-wayland" ''
    #!${pkgs.stdenv.shell}
    chromium --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';
  chromiumWaylandPkg = with pkgs; stdenv.mkDerivation {
    name = "chromium-wayland";
    version = chromium.version;

    nativeBuildInputs = [ copyDesktopItems ];
    desktopItems = [
      (makeDesktopItem rec {
        name = "chromium-wayland";
        exec = name;
        desktopName = "Chromium Wayland";
        genericName = "Web Browser";
      })
    ];

    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${chromiumWayland}/bin/chromium-wayland $out/bin/chromium-wayland
    '';
  };

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

  colorSchemeDark = rec {
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
    indicator = "#111111"; # don't care
  };
  fonts = [ fontComb ];
in
{
  home-manager.users.patriot = { config, pkgs, ... }: {
    imports = [ ../profiles/hikari.nix ];

    /*gtk = {
      enable = false;
      font = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans 12";
      };
      iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus Dark";
      };
      theme = {
      package = pkgs.numix-gtk-theme;
      name = "Numix Dark";
      };
      };

      qt = {
      enable = false;
      style = {
      package = pkgs.adwaita-qt;
      name = "adwaita-dark";
      };
      };*/

    fonts.fontconfig.enable = true;
    home = {
      homeDirectory = nixosConfig.users.users.patriot.home;
      packages = with pkgs;
        [
          discord
          # Font stuff
          fontPackage
          noto-fonts-cjk
          noto-fonts-emoji-blob-bin
          font-awesome
          (nerdfonts.override { fonts = [ "Iosevka" ]; })
          # Programs
          audacity
          krita
          kdenlive
          gnome3.seahorse
          gnome3.gnome-boxes
          wine-staging
          cachix
          chromiumWaylandPkg
          appimage-run
          bitwarden
          pfetch
          neofetch
          gnupg
          imv
          mpv
          youtube-dl
          ffmpeg
          mupdf
          transmission-qt
          steam-run
          lutris
          xdg_utils
          tagref
          libreoffice-fresh
          mako
          hydrus
          musikcube
          qt5ct
          phantomstyle
          papirus-icon-theme
          pcmanfm-qt
        ] ++ kideDeps;
    };

    wayland.windowManager = {
      hikari = {
        enable = false;
        inherit font;
      };
      sway = {
        enable = true;
        extraSessionCommands = ''
          #export SDL_VIDEODRIVER=wayland
          # needs qt5.qtwayland in systemPackages
          #export QT_QPA_PLATFORM=wayland
          #export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
          # Fix for some Java AWT applications (e.g. Android Studio),
          # use this if they aren't displayed properly:
          export _JAVA_AWT_WM_NONREPARENTING=1
          export QT_QPA_PLATFORMTHEME=qt5ct
          export QT_PLATFORM_PLUGIN=qt5ct
        '';
        wrapperFeatures.gtk = true;
        config = {
          inherit fonts;
          bars = [{
            command = "${pkgBin "waybar"}";
          }];
          colors = {
            background = "#${bgColor}";
            focused = addIndSway focusedWorkspace;
            focusedInactive = addIndSway inactiveWorkspace;
            unfocused = addIndSway activeWorkspace;
            urgent = addIndSway urgentWorkspace;
          };
          gaps.smartBorders = "on";
          menu = "${pkgBin "rofi"} -show drun | ${pkgs.sway}/bin/swaymsg --";
          modifier = "Mod4";
          terminal = pkgBin "alacritty";
          keybindings =
            let
              mod = config.wayland.windowManager.sway.config.modifier;
              cat = pkgs.coreutils + "/bin/cat";
              grim = pkgBin "grim";
              slurp = pkgBin "slurp";
              pactl = pkgs.pulseaudio + "/bin/pactl";
              playerctl = pkgBin "playerctl";
              wf-recorder = pkgBin "wf-recorder";
              wl-copy = pkgs.wl-clipboard + "/bin/wl-copy";
              wl-paste = pkgs.wl-clipboard + "/bin/wl-paste";
              shotFile = config.home.homeDirectory
                + "/shots/shot_$(date '+%Y_%m_%d_%H_%M')";
            in
            lib.mkOptionDefault {
              "${mod}+q" = "kill";
              "${mod}+Shift+e" = "exit";
              "${mod}+Shift+r" = "reload";
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
              "Mod1+Shift+r" =
                ''exec ${wf-recorder} -g "$(${slurp})" -f "${shotFile}.mp4"'';
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
          output = {
            "*" = {
              bg = config.home.homeDirectory + "/wallpaper.png" + " fill";
            };
          };
        };
      };
    };

    programs = {
      alacritty = {
        enable = true;
        settings = {
          font = {
            normal = { family = font; };
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
        enable = false;
        extensions = [
          "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock
          "nngceckbapebfimnlniiiahkandclblb" # bitwarden
          "ldpochfccmkkmhdbclfhpagapcfdljkj" # decentraleyes
          "annfbnbieaamhaimclajlajpijgkdblo" # dark theme
          "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
          "hlepfoohegkhhmjieoechaddaejaokhf" # github refined
        ];
      };
      qutebrowser = {
        enable = true;
        settings = {
          content.javascript.enabled = false;
          colors.webpage.darkmode.enabled = false;
          tabs = {
            show = "multiple";
            tabs_are_windows = true;
          };
        };
        extraConfig =
          let
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
          in
          ''
            ${lib.concatStrings (map enableJsForDomain domains)}
          '';
      };
      git = {
        enable = true;
        aliases = {
          a = "add";
          b = "branch";
          c = "commit";
          d = "diff";
          l = "log";
          s = "status";
          co = "checkout";
          dc = "diff --cached";
          qc = "commit -am";
          pl = "pull";
          ps = "push";
          rb = "rebase";
          rs = "restore";
          rv = "revert";
          ss = "stash";
          rst = "reset";
          rss = "restore --staged";
          ssp = "stash pop";
          ssl = "stash list";
          ssd = "stash drop";
        };
        extraConfig = { pull.rebase = true; };
        lfs.enable = true;
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
        plugins =
          let
            fast-syntax-highlighting = rec {
              name = "fast-syntax-highlighting";
              src = pkgs."zsh-${name}".out;
            };
            per-directory-history = {
              name = "per-directory-history";
              src = pkgs.fetchFromGitHub {
                owner = "jimhester";
                repo = "per-directory-history";
                rev = "d2e291dd6434e340d9be0e15e1f5b94f32771c06";
                hash = "sha256-VHRgrVCqzILqOes8VXGjSgLek38BFs9eijmp0JHtD5Q=";
              };
            };
          in
          [ fast-syntax-highlighting per-directory-history ];
        # xdg compliant
        dotDir = ".config/zsh";
        history.path = ".local/share/zsh/history";
        envExtra = ''
          #export SDL_VIDEODRIVER=wayland
          # needs qt5.qtwayland in systemPackages
          #export QT_QPA_PLATFORM=wayland
          #export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
          # Fix for some Java AWT applications (e.g. Android Studio),
          # use this if they aren't displayed properly:
          export _JAVA_AWT_WM_NONREPARENTING=1
          export QT_QPA_PLATFORMTHEME=qt5ct
          export QT_PLATFORM_PLUGIN=qt5ct
        '';
        loginExtra =
          ''
            if [ "$(${pkgs.coreutils}/bin/tty)" = "/dev/tty1" ]; then
                exec sway
            fi
          '';
        initExtra = ''
          function tomp4 () {
            ${pkgs.ffmpeg}/bin/ffmpeg -i $1 -c:v libx264 -preset slow -crf 30 -c:a aac -b:a 128k $2
          }
        
          bindkey "$terminfo[kRIT5]" forward-word
          bindkey "$terminfo[kLFT5]" backward-word
          zstyle ':completion:*' menu select

          eval "$(zoxide init zsh)"
        '';
        shellAliases = nixosConfig.environment.shellAliases // {
          rember = ''
            ${pkgs.kakoune-unwrapped}/bin/kak -e "try %(gtd-jump-today)" "${config.home.homeDirectory}/rember/stuff$(date '+_%m_%Y').gtd"
          '';
        };
      };
      starship = {
        enable = true;
        settings = {
          add_newline = false;
          character.symbol = ">";
          directory = {
            truncation_length = 2;
            truncate_to_repo = false;
          };
        };
      };
      direnv = {
        enable = true;
        enableNixDirenvIntegration = true;
      };
      fzf.enable = true;
      rofi =
        let
          bgc = "#${bgColor}";
          fgc = "#${fgColor}";
          acc = "#${acColor}";
        in
        {
          enable = true;
          colors = {
            window = {
              background = bgc;
              border = bgc;
              separator = bgc;
            };
            rows = {
              normal = {
                background = bgc;
                foreground = fgc;
                backgroundAlt = bgc;
                highlight = {
                  background = bgc;
                  foreground = acc;
                };
              };
            };
          };
          font = fontComb;
          separator = "none";
          terminal = pkgBin "alacritty";
        };
      waybar =
        let
          swayEnabled = config.wayland.windowManager.sway.enable;
        in
        {
          enable = swayEnabled || config.wayland.windowManager.hikari.enable;
          settings = [{
            layer = "top";
            position = "top";
            modules-left = if swayEnabled then [ "sway/workspaces" ] else [ ];
            modules-center = if swayEnabled then [ "sway/window" ] else [ ];
            modules-right =
              [ "pulseaudio" "cpu" "memory" "temperature" "clock" "tray" ];
            modules = {
              "tray" = { spacing = 8; };
              "cpu" = { format = "/cpu {usage}/"; };
              "memory" = { format = "/mem {}/"; };
              "temperature" = {
                hwmon-path = "/sys/class/hwmon/hwmon1/temp2_input";
                format = "/tmp {temperatureC}C/";
              };
              "pulseaudio" = {
                format = "/vol {volume}/ {format_source}";
                format-bluetooth = "/volb {volume}/ {format_source}";
                format-bluetooth-muted = "/volb/ {format_source}";
                format-muted = "/vol/ {format_source}";
                format-source = "/mic {volume}/";
                format-source-muted = "/mic/";
              };
            };
          }];
          style =
            let
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
            in
            ''
              * {
                  border: none;
                  border-radius: 0;
                  /* `otf-font-awesome` is required to be installed for icons */
                  font-family: ${font};
                  font-size: 13px;
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
      vscode = {
        enable = true;
        package = pkgs.vscodium;
        extensions =
          let
            mkExt = n: v: p: s: { name = n; version = v; publisher = p; sha256 = s; };
          in
          (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            # Rust
            (mkExt "rust-analyzer" "0.2.513" "matklad" "sha256-95B5AZkw4MigZ1XsnALzy9Th9U59SDLrGCpA1FYy6vQ=")
            (mkExt "even-better-toml" "0.11.1" "tamasfe" "sha256-0JpOydgcEs9PR2wUiVT9cmp9OnLX01idt0/d9UE+VI4=")
            (mkExt "crates" "0.5.7" "serayuzgur" "sha256-g0eobd8QlBgWOOhqQdJX1rsplBECryRC3+9Wg8yqKeA=")
            # Nix
            (mkExt "nix-env-selector" "1.0.4" "arrterian" "sha256-qsz8Gj9s68BIaia80p5lw3J0OFLU3/om4XPNwn69oDY=")
            # Go
            (mkExt "Go" "0.23.1" "golang" "sha256-+WGWGzCBNktZFyaupiUi9DwgTTfI3uUy9UmOiS8Js6k=")
            # Flutter and dart
            (mkExt "flutter" "3.20.0" "Dart-Code" "sha256-egnfhJrTn6JG0jxvwyQiXIcyfpdGs0IGVor1LKf6+wI=")
            (mkExt "dart-code" "3.20.0" "Dart-Code" "sha256-HeTJHH22ltrlSQkxsw+3ktO2Zvt1n+LKHeHx3rAHEL0=")
            # protobuf
            (mkExt "vscode-proto3" "0.5.3" "zxh404" "sha256-oUSih+YdAXYkTNejZBJjcXewQewgQFMGhAFdJ/CBMd4=")
            # git
            (mkExt "gitlens" "11.3.0" "eamodio" "sha256-m2Zn+e6hj59SujcW5ptdrYDrc4CviZ4wyCndO2BhyF8=")
            (mkExt "vscode-commitizen" "0.12.1" "KnisterPeter" "sha256-TpfRzePDeXQlSMmjRhphN3XXTc+pp92JySZoe6ltxZg=")
            # Customization
            # (mkExt "dance" "0.3.2" "gregoire" "sha256-+g8EXeCkPOPvZ60JoXkGTeSXYWrXmKrcbUaEfDppdgA=")
            (mkExt "material-icon-theme" "4.4.0" "PKief" "sha256-yiM+jtc7UW8PQTwmHmXHSSmvYC73GLh/cLYnmYqONdU=")
            (mkExt "github-vscode-theme" "1.1.5" "github" "sha256-EPAJjM4CbR8MhV+3pm6mC12KzSt2Em6pT+c2HknNntI=")
            (mkExt "koka" "0.0.1" "maelvalais" "sha256-ty8Mql19HgUWForggeZuHQpzTbmmB/eBFHqof5ZMKr0=")
          ]) ++ (with pkgs.vscode-extensions; [ a5huynh.vscode-ron vadimcn.vscode-lldb jnoortheen.nix-ide ]);
        userSettings = {
          "workbench.iconTheme" = "material-icon-theme";
          "workbench.colorTheme" = "GitHub Dark";
          "rust-analyzer.cargo.allFeatures" = true;
          "rust-analyzer.cargo.loadOutDirsFromCheck" = true;
          "rust-analyzer.procMacro.enable" = true;
          "editor.fontFamily" = "'${font}'";
          "debug.console.fontFamily" = "${font}";
          "debug.console.fontSize" = 12;
          "terminal.integrated.fontSize" = 12;
          "go.useLanguageServer" = true;
          "rust-analyzer.checkOnSave.command" = "clippy";
        };
      };
    };

    services = {
      gpg-agent = rec {
        enable = true;
        enableSshSupport = true;
        sshKeys = [ "8369D9CA26C3EAAAB8302A88CEE6FD14B58AA965" ];
        defaultCacheTtl = 3600 * 6;
        defaultCacheTtlSsh = defaultCacheTtl;
        maxCacheTtl = 3600 * 24;
        maxCacheTtlSsh = maxCacheTtl;
        grabKeyboardAndMouse = false;
        pinentryFlavor = "qt";
      };
    };

    xdg = {
      enable = true;
      configFile = {
        # "oguri/config".text = ''
        #   [output *]
        #   image=/home/patriot/wallpaper.gif
        #   filter=nearest
        #   scaling-mode=fill
        #   anchor=center
        # '';
        "kak/user/kakrc".text = ''
          source "%val{config}/user/color/colorscheme.kak"
        '';
        "kak/user/color/colorscheme.kak".text = ''
          evaluate-commands %sh{
            fg="rgb:${colorScheme.primary.normal.foreground}"
            bg="rgb:${colorScheme.primary.normal.background}"
            br_fg="rgb:${colorScheme.primary.bright.foreground}"
            br_bg="rgb:${colorScheme.primary.bright.background}"

            red="rgb:${colorScheme.normal.red}"
            green="rgb:${colorScheme.normal.green}"
            yellow="rgb:${colorScheme.normal.yellow}"
            blue="rgb:${colorScheme.normal.blue}"
            magenta="rgb:${colorScheme.normal.magenta}"
            cyan="rgb:${colorScheme.normal.cyan}"

            br_red="rgb:${colorScheme.bright.red}"
            br_green="rgb:${colorScheme.bright.green}"
            br_yellow="rgb:${colorScheme.bright.yellow}"
            br_blue="rgb:${colorScheme.bright.blue}"
            br_magenta="rgb:${colorScheme.bright.magenta}"
            br_cyan="rgb:${colorScheme.bright.cyan}"

            echo "
              set-face global value $yellow+b
              set-face global type $br_yellow
              set-face global variable $magenta
              set-face global module $blue
              set-face global function $br_cyan
              set-face global string $br_green
              set-face global keyword $br_red+b
              set-face global operator $br_cyan
              set-face global attribute $yellow
              set-face global comment $fg
              set-face global meta $br_yellow
              set-face global builtin $br_fg+b

              set-face global title $blue+u
              set-face global header $br_cyan+u
              set-face global bold $br_fg+b
              set-face global italic $br_fg+i
              set-face global mono $br_green
              set-face global block $yellow
              set-face global link $blue
              set-face global bullet $br_magenta
              set-face global list $magenta

              set-face global Default $br_fg,$bg
              set-face global PrimarySelection $bg,$br_fg
              set-face global SecondarySelection $br_fg,$br_bg+i
              set-face global PrimaryCursor $bg,$red+b
              set-face global SecondaryCursor $bg,$br_cyan+i
              set-face global MatchingChar $bg,$blue
              set-face global Search $br_fg,$green
              set-face global CurrentWord $br_fg,$blue

              set-face global MenuForeground $cyan,$br_bg+b
              set-face global MenuBackground $br_fg,$bg

              set-face global Information $br_yellow,$bg
              set-face global Error $br_bg,$br_red

              set-face global BufferPadding $bg,$bg
              set-face global Whitespace $bg
              set-face global StatusLine $br_fg,$bg
              set-face global StatusLineInfo $yellow,$bg

              set-face global LineNumbers default
              set-face global LineNumberCursor default,default+r
            "
          }
        '';
        "kak-lsp/kak-lsp.toml".text = ''
          snippet_support = true
          verbosity = 2

          [semantic_scopes]
          variable = "variable"
          entity_name_function = "function"
          entity_name_type = "type"
          variable_other_enummember = "variable"
          entity_name_namespace = "module"

          [semantic_tokens]
          type = "type"
          variable = "variable"
          namespace = "module"
          function = "function"
          string = "string"
          keyword = "keyword"
          operator = "operator"
          comment = "comment"

          [semantic_modifiers]
          documentation = "documentation"
          readonly = "default+d"

          [server]
          timeout = 1800

          [language.rust]
          filetypes = ["rust"]
          roots = ["Cargo.toml"]
          command = "${pkgBin "rust-analyzer"}"

          [language.nix]
          filetypes = ["nix"]
          roots = ["flake.nix", "shell.nix", ".git"]
          command = "${pkgBin "rnix-lsp"}"
        '';
        "nix/nix.conf".text = nixosConfig.nix.extraOptions;
        "nixpkgs/config.nix".text = ''
          {
            android_sdk.accept_license = true;
            allowUnfree = true;
          }
        '';
      } // kideFiles;
    };
  };
}
