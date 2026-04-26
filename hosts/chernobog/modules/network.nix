{
  imports = [ ../../../modules/network/dns/systemd.nix ];

  networking.useDHCP = true;

  # networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [22];
}
