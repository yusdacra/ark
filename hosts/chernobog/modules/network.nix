{
  imports = [ ../../../modules/network/dns/systemd.nix ];

  networking.useDHCP = true;
}
