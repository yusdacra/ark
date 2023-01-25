{
  imports = [../dns ../iwd];
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
  };
}
