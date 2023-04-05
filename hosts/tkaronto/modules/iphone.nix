{pkgs, ...}: {
  services.usbmuxd.enable = true;
  environment.systemPackages = [pkgs.libimobiledevice];
}
