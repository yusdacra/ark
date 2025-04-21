{pkgs, config, ...}: {
  services.nginx.virtualHosts."9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa" = {
    locations."/".alias = toString (pkgs.writeText "index.txt" ''
      meow :3c
    '');
    quic = true;
    kTLS = true;
  };
}
