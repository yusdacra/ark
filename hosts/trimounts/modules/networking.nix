{
  networking.enableIPv6 = true;
  networking.interfaces.ens3 = {
    ipv6.addresses = [{
      address = "2a0a:4cc0:c1:e83d::b00b";
      prefixLength = 64;
    }];
  };
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens3";
  };
  
  networking.firewall.enable = true;
}
