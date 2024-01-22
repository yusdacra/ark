{
  pkgs,
  lib,
  ...
}: {
  services.gnome = {
    gnome-keyring.enable = true;
    core-shell.enable = true;
    core-os-services.enable = true;
    at-spi2-core.enable = lib.mkForce false;
    gnome-browser-connector.enable = true;
    gnome-online-accounts.enable = false;
    gnome-online-miners.enable = lib.mkForce false;
    tracker-miners.enable = false;
    tracker.enable = false;
    sushi.enable = true;
    gnome-remote-desktop.enable = false;
  };
  services.tumbler.enable = true;
  programs = {
    geary.enable = lib.mkForce false;
    gnome-terminal.enable = true;
    evince.enable = true;
  };
  services.xserver = {
    enable = true;
    desktopManager = {
      gnome.enable = true;
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
    gnomeExtensions.unite
    gnome.gnome-tweaks
    ffmpegthumbnailer
    webp-pixbuf-loader
    yaru-theme
  ];
  environment.gnome.excludePackages = with pkgs; [
    gnome-console
    gnome-tour
    gnome.gnome-maps
  ];
  # environment.etc."environment.d/10-use-amd.conf".text = ''
  #   __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/glvnd/egl_vendor.d/50_mesa.json
  # '';
}
