{ lib, ... }:
{
  networking.resolvconf.useLocalResolver = true;
  networking.networkmanager.dns = lib.mkForce "none";
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      server_names = [
        "cloudflare"
        "cloudflare-ipv6"
      ];
    };
  };
}
