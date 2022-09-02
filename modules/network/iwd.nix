{
  imports = [./dns];
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Network = { EnableIPv6 = true; };
      Settings = { AutoConnect = true; };
    };
  };
  networking.networkmanager.wifi.backend = "iwd";
  services.connman.wifi.backend = "iwd";
}
