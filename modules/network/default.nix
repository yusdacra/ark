{
  imports = [./networkmanager];
  systemd.network.wait-online.enable = false;
}
