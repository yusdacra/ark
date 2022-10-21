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
  programs.zsh.loginExtra = ''
    xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
  '';
}
