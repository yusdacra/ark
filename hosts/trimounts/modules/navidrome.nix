{lib, pkgs, config, ...}:
let
  domain = "tunes.ptr.pet";
  callieMount = "/music/callie";
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
      Scanner.ScanOnStartup = false;
    };
  };
  systemd.services.navidrome.serviceConfig = {
    BindReadOnlyPaths = lib.mkForce ["/music" callieMount "/etc" "/nix/store"];
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

  age.secrets.callieMusic = {
    file = ../../../secrets/callieMusic.age;
    mode = "0600";
  };

  systemd.services.music-callie-mnt = {
    description = "geesefs mount (callie) for music";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "navidrome.service" ];
    before = [ "navidrome.service" ];
    
    serviceConfig = {
      Type = "forking";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${callieMount}";
      ExecStart = ''
        ${pkgs.geesefs}/bin/geesefs \
          --endpoint https://s3.nematodes.net \
          --region us-east-1 \
          --shared-config ${config.age.secrets.callieMusic.path} \
          --cache %C/geesefs-callie \
          --stat-cache-ttl 3600s \
          --http-timeout 2m0s \
          --read-retry-interval 30s \
          --read-retry-max-interval 2m0s \
          --read-ahead-large 20000 \
          --max-parallel-parts 2 \
          --max-parallel-copy 2 \
          --ignore-fsync \
          --disable-xattr \
          --no-specials \
          -o allow_other \
          -o ro \
          musica ${callieMount}
      '';
      ExecStop = "${pkgs.fuse}/bin/fusermount -uz ${callieMount}";
      Restart = "on-failure";
      RestartSec = "10s";
      RuntimeDirectory = "geesefs-callie";
      CacheDirectory = "geesefs-callie";
    };
  };
}