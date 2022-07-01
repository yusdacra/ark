{
  imports = [./dns];
  networking.dhcpcd.enable = true;
  networking.useDHCP = false;
  networking.dhcpcd.extraConfig = ''
    noarp
    nodelay
  '';
}
