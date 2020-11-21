{
  imports = [ ./dns ];

  networking.useDHCP = false;

  networking.dhcpcd.extraConfig = ''
    noarp
    nodelay
  '';
}
