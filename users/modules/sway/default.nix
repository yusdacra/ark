{
  config,
  nixosConfig,
  pkgs,
  lib,
  tlib,
  ...
}: {
  imports = [
    ../wayland
    ../swaylock
    ../wlsunset
    ../dunst
    ../rofi
    # ./swayidle.nix
  ];
  wayland.windowManager = {
    sway = let
      mkRofiCmd = args: "${config.programs.rofi.package}/bin/rofi ${lib.concatStringsSep " " args} | ${pkgs.sway}/bin/swaymsg --";
      inherit (tlib) pkgBin;
    in {
      enable = true;
      extraSessionCommands = ''
        export QT_QPA_PLATFORM=wayland
      '';
      wrapperFeatures.gtk = true;
      extraConfig = ''
        exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
        exec xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
      '';
      config = {
        bars = [];
        gaps.smartBorders = "on";
        menu = mkRofiCmd [
          "-show"
          "drun"
        ];
        modifier = "Mod4";
        terminal = config.settings.terminal.binary;
        keybindings = let
          mod = config.wayland.windowManager.sway.config.modifier;

          cat = pkgs.coreutils + "/bin/cat";
          grim = pkgBin pkgs.grim;
          slurp = pkgBin pkgs.slurp;
          pactl = pkgs.pulseaudio + "/bin/pactl";
          playerctl = pkgBin pkgs.playerctl;
          wf-recorder = pkgBin pkgs.wf-recorder;
          wl-copy = pkgs.wl-clipboard + "/bin/wl-copy";
          wlogout = pkgBin pkgs.wlogout;
          light = pkgBin pkgs.light;

          shotFile = config.home.homeDirectory + "/shots/shot_$(date '+%Y_%m_%d_%H_%M')";
          shotDir = config.home.homeDirectory + "/shots";
        in
          lib.mkOptionDefault
          {
            "${mod}+Escape" = "exec ${wlogout} -p layer-shell";
            "${mod}+q" = "kill";
            "${mod}+Shift+e" = "exit";
            "${mod}+Shift+r" = "reload";
            # Screenshot and copy it to clipboard
            "Mod1+s" = ''
              exec export SFILE="${shotFile}.png" && mkdir -p ${shotDir} && ${grim} "$SFILE" && ${cat} "$SFILE" | ${wl-copy} -t image/png
            '';
            # Save selected area as a picture and copy it to clipboard
            "Mod1+Shift+s" = ''
              exec export SFILE="${shotFile}.png" && mkdir -p ${shotDir} && ${grim} -g "$(${slurp})" "$SFILE" && ${cat} "$SFILE" | ${wl-copy} -t image/png
            '';
            # Record screen
            "Mod1+r" = ''exec mkdir -p ${shotDir} && ${wf-recorder} -x yuv420p -f "${shotFile}.mp4"'';
            # Record an area
            "Mod1+Shift+r" = ''exec mkdir -p ${shotDir} && ${wf-recorder} -x yuv420p -g "$(${slurp})" -f "${shotFile}.mp4"'';
            # Stop recording
            "Mod1+c" = "exec pkill -INT wf-recorder";
            "XF86AudioRaiseVolume" = "exec ${pactl} set-sink-volume 0 +5%";
            "XF86AudioLowerVolume" = "exec ${pactl} set-sink-volume 0 -5%";
            "XF86AudioMute" = "exec ${pactl} set-sink-mute 0 toggle";
            "XF86AudioPlay" = "exec ${playerctl} play-pause";
            "XF86AudioPrev" = "exec ${playerctl} previous";
            "XF86AudioNext" = "exec ${playerctl} next";
            "XF86AudioStop" = "exec ${playerctl} stop";
            "XF86MonBrightnessUp" = "exec ${light} -T 1.4";
            "XF86MonBrightnessDown" = "exec ${light} -T 0.72";
          };
        input = {
          "13364:832:Keychron_Keychron_V4_Keyboard" = {
            xkb_layout = nixosConfig.services.xserver.layout;
          };
          "1:1:AT_Translated_Set_2_keyboard" = {
            xkb_layout = "tr";
          };
          "type:pointer" = {
            accel_profile = "flat";
          };
          "type:touchpad" = {
            accel_profile = "adaptive";
            tap = "enabled";
            scroll_method = "two_finger";
            dwt = "enabled";
            events = "disabled_on_external_mouse";
          };
        };
        output = {
          "*" = {
            bg = "${config.stylix.image} fill";
          };
          "eDP-1" = {
            scale = "2";
            adaptive_sync = "on";
          };
          "HDMI-A-1" = {
            mode = "1920x1080@74.973Hz";
          };
        };
      };
    };
  };
}
