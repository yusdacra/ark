{
  pkgs,
  lib,
  ...
}: {
  services.gnome = {
    gnome-keyring.enable = true;
    core-shell.enable = true;
    core-os-services.enable = true;
    at-spi2-core.enable = true;
    gnome-browser-connector.enable = true;
    gnome-online-accounts.enable = true;
    gnome-online-miners.enable = true;
    tracker-miners.enable = true;
    tracker.enable = true;
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
      autoLogin = {
        enable = true;
        user = "patriot";
      };
      gdm = {
        enable = true;
        wayland = true;
      };
      startx.enable = false;
    };
  };
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };
  services.power-profiles-daemon.enable = false;
  environment.systemPackages = with pkgs; [gnomeExtensions.unite gnome.gnome-tweaks ffmpegthumbnailer webp-pixbuf-loader];
  environment.gnome.excludePackages = with pkgs; [gnome-console gnome-tour gnome.gnome-maps];
}
