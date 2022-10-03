{lib, ...}: {
  services.gnome = {
    gnome-keyring.enable = true;
    core-shell.enable = true;
    core-os-services.enable = true;
    at-spi2-core.enable = true;
    chrome-gnome-shell.enable = false;
    gnome-online-accounts.enable = false;
    gnome-online-miners.enable = lib.mkForce false;
    gnome-remote-desktop.enable = false;
    core-utilities.enable = false;
    tracker-miners.enable = false;
    tracker.enable = false;
    gnome-settings-daemon.enable = lib.mkForce false;
    sushi.enable = false;
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
}
