{pkgs, ...}: {
  hardware.bluetooth.enable = true;
  hardware.steam-hardware.enable = true;

  environment.systemPackages = [pkgs.bluetuith];
}
