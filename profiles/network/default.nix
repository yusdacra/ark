{
  imports = [ ./dns ];

  networking.networkmanager.enable = false;
  networking.dhcpcd.enable = true;
  networking.useDHCP = false;
  networking.dhcpcd.extraConfig = ''
    noarp
    nodelay
  '';

  /*systemd.network = {
    enable = true;
    networks = {
      internet0 = {
        matchConfig = { Name = "enp6s0"; };
        networkConfig = {
          Address = "192.168.1.33";
          Gateway = "192.168.1.255";
        };
      };
    };
  };*/
}
