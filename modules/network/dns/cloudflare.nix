{
  networking.resolvconf.useLocalResolver = true;
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      server_names = ["cloudflare" "cloudflare-ipv6"];
    };
  };
}
