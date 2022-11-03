{pkgs, ...}: {
  home.packages = with pkgs; [
    wl-clipboard
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
  };

  xdg.configFile = {
    "environment.d/10-apply-wayland-env.conf".text = ''
      NIXOS_OZONE_WL=1
      MOZ_ENABLE_WAYLAND=1
      XDG_SESSION_TYPE=wayland
    '';
  };
}
