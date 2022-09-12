{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../wayland
    ../swaylock
    ../wlsunset
    ./swayidle.nix
    "${inputs.fufexan}/home/graphical/eww"
    inputs.hyprland.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    wf-recorder
    xorg.xprop
    inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
    light
    playerctl
    wlogout
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    extraConfig = let
      launcher = "rofi -show drun";
      term = config.settings.terminal.name;

      notify-date = with pkgs;
        writers.writeBash "notify-date" ''
          ${libnotify}/bin/notify-send -t 1000 "       $(${coreutils}/bin/date +'%H:%M %d/%m/%Y')"
        '';
    in ''
      # should be configured per-profile
      monitor=eDP-1,preferred,auto,1.6
      monitor=HDMI-A-1,1920x1080@75,auto,1
      workspace=eDP-1,1
      workspace=HDMI-A-1,2

      exec-once=xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
      exec-once=swaybg -i ~/.config/wallpaper
      exec-once=eww daemon
      exec-once=eww open bar

      input {
          kb_layout=tr
          follow_mouse=1
          force_no_accel=1
          touchpad {
            natural_scroll=1
          }
      }
      general {
          main_mod=SUPER
          gaps_in=5
          gaps_out=5
          border_size=0
      }
      decoration {
          rounding=16
          blur=1
          blur_size=3
          blur_passes=3
          blur_new_optimizations=1
          drop_shadow=0
          shadow_ignore_window=1
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
      misc {
        no_vfr=0
      }

      windowrule=float,title:^(Media viewer)$
      windowrule=float,title:^(Picture-in-Picture)$
      windowrule=float,title:^(Firefox — Sharing Indicator)$
      windowrule=move 0 0,title:^(Firefox — Sharing Indicator)$


      bind=SUPER,Escape,exec,wlogout -p layer-shell
      bind=SUPER,L,exec,swaylock
      bind=SUPER,RETURN,exec,${term}
      bind=SUPER,D,exec,${launcher}
      bind=SUPER,Q,killactive,
      bind=SUPERSHIFT,E,exec,pkill Hyprland
      bind=SUPER,F,fullscreen,
      bind=SUPER,P,pseudo,
      bind=SUPER,T,exec,${notify-date}
      bind=SUPERSHIFT,T,togglefloating,

      bind=,XF86AudioPlay,exec,playerctl play-pause
      bind=,XF86AudioPrev,exec,playerctl previous
      bind=,XF86AudioNext,exec,playerctl next

      bindle=,XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 6%+
      bindle=,XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 6%-
      bind=,XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind=,XF86AudioMicMute,exec,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

      bind=,XF86MonBrightnessUp,exec,light -A 5
      bind=,XF86MonBrightnessDown,exec,light -U 5

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

      # screenshot
      bind=,Print,exec,grimblast --notify copysave area
      bind=SUPERSHIFT,R,exec,grimblast --notify copysave area
      bind=CTRL,Print,exec,grimblast --notify --cursor copysave output
      bind=SUPERSHIFTCTRL,R,exec,grimblast --notify --cursor copysave output
      bind=ALT,Print,exec,grimblast --notify --cursor copysave screen
      bind=SUPERSHIFTALT,R,exec,grimblast --notify --cursor copysave screen
    '';
  };
}
