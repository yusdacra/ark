{
  config,
  pkgs,
  ...
}: let
  run-as-service = slice:
    pkgs.writeShellScript "as-systemd-transient" ''
      exec ${pkgs.systemd}/bin/systemd-run \
        --slice=app-${slice}.slice \
        --property=ExitType=cgroup \
        --user \
        --wait \
        bash -lc "exec apply-hm-env $@"
    '';
  launcher = "rofi";
  launcherCmd = "${launcher} -show drun";
  term = config.settings.terminal.name;
in {
  wayland.windowManager.hyprland.extraConfig = ''
    # should be configured per-profile
    monitor=eDP-1,preferred,0x0,1.6
    monitor=HDMI-A-1,1920x1080@75,auto,1
    workspace=eDP-1,1
    workspace=HDMI-A-1,2

    exec-once=xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
    exec-once=swaybg -i ~/.config/wallpaper
    exec-once=mpvpaper -p -o "no-audio loop-file=inf" eDP-1 ~/.config/wallpaper.mp4
    exec-once=eww open-many bar notifications_win

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
        animation=fade,1,4,default
        animation=workspaces,1,2,default,slide
    }
    dwindle {
      pseudotile=1
      preserve_split=1
      no_gaps_when_only=1
    }
    misc {
      no_vfr=0
    }

    # window rules
    windowrule=float,title:^(Media viewer)$
    windowrule=float,title:^(Picture-in-Picture)$
    windowrule=pin,title:^(Picture-in-Picture)$
    windowrule=float,title:^(Firefox — Sharing Indicator)$
    windowrule=move 0 0,title:^(Firefox — Sharing Indicator)$

    # window rules for organization
    windowrule=workspace 1,title:^(Firefox)$
    windowrule=workspace 2,title:^(Discord)$
    windowrule=workspace 2,title:^(WebCord)$
    windowrule=workspace 3,title:^(foot)$

    # mouse
    bindm=SUPER,mouse:272,movewindow
    bindm=SUPER,mouse:273,resizewindow
    bindm=SUPERALT,mouse:272,resizewindow

    # compositor binds
    bind=SUPERSHIFT,E,exec,pkill Hyprland
    bind=SUPER,Q,killactive,
    bind=SUPER,F,fullscreen,
    bind=SUPER,P,pseudo,
    bind=SUPERSHIFT,T,togglefloating,

    # utilities
    bind=SUPER,L,exec,swaylock
    bind=SUPER,RETURN,exec, ${term}
    bind=SUPER,D,exec,pkill ${launcher} || ${launcherCmd}
    bind=SUPER,Escape,exec,wlogout -p layer-shell

    # media management
    bind=,XF86AudioPlay,exec,playerctl play-pause
    bind=,XF86AudioPrev,exec,playerctl previous
    bind=,XF86AudioNext,exec,playerctl next

    # volume management
    bindle=,XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 6%+
    bindle=,XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 6%-
    bind=,XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bind=,XF86AudioMicMute,exec,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

    # brightness management
    bind=,XF86MonBrightnessUp,exec,light -A 5
    bind=,XF86MonBrightnessDown,exec,light -U 5

    # move focus
    bind=SUPER,left,movefocus,l
    bind=SUPER,right,movefocus,r
    bind=SUPER,up,movefocus,u
    bind=SUPER,down,movefocus,d

    # cycle workspaces
    bind=SUPER,bracketleft,workspace,m-1
    bind=SUPER,bracketright,workspace,m+1

    # cycle monitors
    bind=SUPERSHIFT,braceleft,focusmonitor,l
    bind=SUPERSHIFT,braceright,focusmonitor,r

    # workspaces
    ${builtins.concatStringsSep "\n" (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / 10;
          in
            builtins.toString (x + 1 - (c * 10));
        in ''
          bind=SUPER,${ws},workspace,${toString (x + 1)}
          bind=SHIFTSUPER,${ws},movetoworkspacesilent,${toString (x + 1)}
        ''
      )
      10)}

    # screenshot
    bind=,Print,exec,grimblast --notify copysave area
    bind=SUPERSHIFT,R,exec,grimblast --notify copysave area
    bind=CTRL,Print,exec,grimblast --notify --cursor copysave output
    bind=SUPERSHIFTCTRL,R,exec,grimblast --notify --cursor copysave output
    bind=ALT,Print,exec,grimblast --notify --cursor copysave screen
    bind=SUPERSHIFTALT,R,exec,grimblast --notify --cursor copysave screen
  '';
}
