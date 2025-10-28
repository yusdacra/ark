{
  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    configurationLimit = 20;
  };
  boot.loader.efi.canTouchEfiVariables = true;
}
