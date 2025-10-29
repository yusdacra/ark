{
  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    configurationLimit = 20;
    consoleMode = "max";
  };
  boot.loader.efi.canTouchEfiVariables = true;
}
