{
  imports = [./nextdns.nix];
  networking.resolvconf.useLocalResolver = true;
}
