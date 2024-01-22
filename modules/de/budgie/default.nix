{
  pkgs,
  lib,
  ...
}: {
  services.xserver = {
    enable = true;
    desktopManager = {
      budgie.enable = true;
      xterm.enable = false;
    };
    displayManager = {
      gdm = {
        enable = true;
        wayland = false;
      };
      startx.enable = false;
    };
  };
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };
  services.power-profiles-daemon.enable = false;
  environment.systemPackages = with pkgs; [
    ffmpegthumbnailer
    webp-pixbuf-loader
    yaru-theme
  ];
  # environment.etc."environment.d/10-use-amd.conf".text = ''
  #   __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/glvnd/egl_vendor.d/50_mesa.json
  # '';
}
