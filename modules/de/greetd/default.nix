{pkgs, ...}: let
  run-sway = pkgs.writeText "run-sway.sh" ''
    export _JAVA_AWT_WM_NONREPARENTING=1

    export XDG_CURRENT_DESKTOP=sway

    export QT_QPA_PLATFORM=wayland
    export QT_QPA_PLATFORMTHEME=qt5ct
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

    export GDK_BACKEND=wayland
    export WLR_DRM_DEVICES=/dev/dri/card0
    export WL_DRM_DEVICES=/dev/dri/card0
    sway --unsupported-gpu
  '';
in {
  services.greetd = {
    enable = true;
    settings = {
      terminal.vt = 1;
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --issue --time --cmd 'bash --login ${run-sway}'";
        user = "greeter";
      };
    };
  };
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };
}
