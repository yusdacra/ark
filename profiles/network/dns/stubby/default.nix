{
  imports = [ ./nextdns.nix ];

  networking.networkmanager.dns = "none";
  services.stubby.enable = true;
}
