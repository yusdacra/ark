{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../wayland
    inputs.hyprland.homeManagerModules.default
  ];

  home.packages =
    [
      (import "${inputs.fufexan}/home/wayland/screenshot.nix" {inherit pkgs;})
    ]
    ++ (
      with pkgs; [
        wf-recorder
        xorg.xprop
      ]
    );

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.fufexan.packages.${pkgs.system}.hyprland;
    extraConfig = let
      rofi = "${pkgs.rofi-wayland}/bin/rofi";
      launcher = "${rofi} -show drun";
      term = "${pkgs.wezterm}/bin/wezterm";

      swaybg = "${pkgs.swaybg}/bin/swaybg";
      light = "${pkgs.light}/bin/light";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      pulsemixer = "${pkgs.pulsemixer}/bin/pulsemixer";
      wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
      notify-date = with pkgs;
        writers.writeBash "notify-date" ''
          ${libnotify}/bin/notify-send -t 1000 "       $(${coreutils}/bin/date +'%H:%M %d/%m/%Y')"
        '';
    in ''
      # should be configured per-profile
      monitor=,preferred,auto,1.6
      workspace=,1

      exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE
      exec-once=systemctl --user start hyprland-session.target
      exec-once=${swaybg} -i ~/.config/wallpaper

      input {
          kb_layout=tr
          follow_mouse=1
          force_no_accel=1
          touchpad {
            natural_scroll=1
          }
      }
      general {
          sensitivity=1
          main_mod=SUPER
          gaps_in=5
          gaps_out=5
          border_size=0
          damage_tracking=full
      }
      decoration {
          rounding=16
          blur=1
          blur_size=3
          blur_passes=3
          blur_new_optimizations=1
          drop_shadow=1
          shadow_ignore_window=1
          shadow_offset=2 2
          shadow_range=2
          shadow_render_power=1
          col.shadow=0x55000000
      }
      animations {
          enabled=1
          animation=windows,1,3,default,popin 80%
          animation=border,1,2,default
          animation=fade,1,2,default
          animation=workspaces,1,2,default,slide
      }
      dwindle {
          pseudotile=0 # enable pseudotiling on dwindle
      }

      bind=SUPER,RETURN,exec,${term}
      bind=SUPER,D,exec,${launcher}
      bind=SUPER,Q,killactive,
      bind=SUPERSHIFT,E,exec,pkill Hyprland
      bind=SUPER,F,fullscreen,
      bind=SUPER,P,pseudo,
      bind=SUPER,T,exec,${notify-date}
      bind=SUPERSHIFT,T,togglefloating,
      bind=,XF86AudioPlay,exec,${playerctl} play-pause
      bind=,XF86AudioPrev,exec,${playerctl} previous
      bind=,XF86AudioNext,exec,${playerctl} next
      bind=,XF86AudioRaiseVolume,exec,${pulsemixer} --change-volume +6
      bind=,XF86AudioLowerVolume,exec,${pulsemixer} --change-volume -6
      bind=,XF86AudioMute,exec,${pulsemixer} --toggle-mute
      bind=,XF86MonBrightnessUp,exec,${light} -A 5
      bind=,XF86MonBrightnessDown,exec,${light} -U 5

      # move focus
      bind=SUPER,left,movefocus,l
      bind=SUPER,right,movefocus,r
      bind=SUPER,up,movefocus,u
      bind=SUPER,down,movefocus,d

      # go to workspace
      bind=SUPER,1,workspace,1
      bind=SUPER,2,workspace,2
      bind=SUPER,3,workspace,3
      bind=SUPER,4,workspace,4
      bind=SUPER,5,workspace,5
      bind=SUPER,6,workspace,6
      bind=SUPER,7,workspace,7
      bind=SUPER,8,workspace,8
      bind=SUPER,9,workspace,9
      bind=SUPER,0,workspace,10

      # cycle workspaces
      bind=SUPER,bracketleft,workspace,m-1
      bind=SUPER,bracketright,workspace,m+1

      # cycle monitors
      bind=SUPERSHIFT,braceleft,focusmonitor,l
      bind=SUPERSHIFT,braceright,focusmonitor,r

      # move to workspace
      bind=SUPERSHIFT,1,movetoworkspace,1
      bind=SUPERSHIFT,2,movetoworkspace,2
      bind=SUPERSHIFT,3,movetoworkspace,3
      bind=SUPERSHIFT,4,movetoworkspace,4
      bind=SUPERSHIFT,5,movetoworkspace,5
      bind=SUPERSHIFT,6,movetoworkspace,6
      bind=SUPERSHIFT,7,movetoworkspace,7
      bind=SUPERSHIFT,8,movetoworkspace,8
      bind=SUPERSHIFT,9,movetoworkspace,9

      ## screenshot ##
      bind=,Print,exec,screenshot area
      bind=SUPERSHIFT,R,exec,screenshot area

      # monitor
      bind=CTRL,Print,exec,screenshot monitor
      bind=SUPERSHIFTCTRL,R,exec,screenshot monitor

      # all-monitors
      bind=ALT,Print,exec,screenshot all
      bind=SUPERSHIFTALT,R,exec,screenshot all

      # screenrec
      bind=ALT,Print,exec,screenshot rec area
      bind=SUPERSHIFTALT,R,exec,screenshot rec area
    '';
  };
}
