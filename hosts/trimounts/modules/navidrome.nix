{config, ...}:
let
  domain = "tunes.ptr.pet";
in {
  services.navidrome = {
    enable = true;
    openFirewall = false;
    settings = {
      MusicFolder = "/music";
      Port = 9999;
      Address = "0.0.0.0";
      ListenBrainz = {
        Enabled = true;
        BaseURL = "https://piper.kittysay.xyz/1";
      };
      EnableSharing = true;
    };
  };

  security.acme.certs."ptr.pet".extraDomainNames = [domain];
  services.nginx.virtualHosts.${domain} = {
    quic = true;
    kTLS = true;
    useACMEHost = "ptr.pet";
    forceSSL = true;
    locations."/" = {
      proxyPass = with config.services.navidrome.settings; "http://${Address}:${toString Port}";
      proxyWebsockets = true;
    };
  };
}
