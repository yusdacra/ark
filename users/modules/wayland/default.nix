{pkgs, ...}: {
  home.packages = with pkgs; [
    wl-clipboard
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    GDK_SCALE = "2";
  };
}
