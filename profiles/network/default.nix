{
  imports = [./dns];
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  networking.dhcpcd.extraConfig = ''
    noarp
    nodelay
  '';
}
