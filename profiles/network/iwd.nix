{
  imports = [ ./dns ];

  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  services.connman.wifi.backend = "iwd";
}
