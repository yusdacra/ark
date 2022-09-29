{
  networking.resolvconf.useLocalResolver = true;
  services.nextdns = {
    enable = true;
    arguments = ["-config" "75e43d"];
  };
}
