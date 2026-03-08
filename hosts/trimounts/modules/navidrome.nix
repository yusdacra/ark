{lib, pkgs, config, ...}:
let
  domain = "tunes.ptr.pet";
  callieMount = "/music/callie";
in {
  age.secrets.navidrome = {
    file = ../../../secrets/navidrome.age;
    mode = "0600";
  };

  services.navidrome = {
    enable = true;
    openFirewall = false;
    environmentFile = config.age.secrets.navidrome.path;
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
          --endpoint http://homura-v:9000 \
          --region us-east-1 \
          --shared-config ${config.age.secrets.callieMusic.path} \
          --cache %C/geesefs-callie \
          --stat-cache-ttl 1h \
          --http-timeout 5m \
          --read-retry-interval 2s \
          --read-retry-max-interval 30s \
          --read-retry-attempts 5 \
          --read-ahead 10240 \
          --read-ahead-small 512 \
          --read-ahead-large 51200 \
          --read-ahead-parallel 10240 \
          --small-read-count 8 \
          --read-merge 2048 \
          --max-flushers 4 \
          --max-parallel-parts 3 \
          --max-parallel-copy 3 \
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