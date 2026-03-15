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

  users.users.music = {
    isSystemUser = true;
    group = "music";
    shell = pkgs.shadow;
    openssh.authorizedKeys.keys = [
      # ana
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCS9VBRE13jojnqVjuUZWTcOK8GokDDlk2U0i61vEJizVzNowGnIAbwq0cOaFEBX4JBkOa4I8Ku2Pw7fODuoehSK/t7FrfXExk2PBT3k0mfzqQYxfq5bzae7AWr7n/sKUBTtvHSACfidxzQpV7VSgW68jqdOt6h7FHSeS2jac7wUNPobL0uCkFB4FiEQOnIqlRGSSabVemL7bC9H9lUyOODSTthiq9S3pPYknyHDRKUtSCSw4pfpasr4bxDVSW99h3GBcW0hZbpw5bwlxQlwbclxQDnn7XJhWpq6zL/2ScVGJgd94z7FshKoF5IFTk6e7a/Ouv4Ato4hRLxEe5u70CH"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUIHFy8lBU8Iy5253Lglw0v67k9ozxjLWprjTjwTsrm dusk@devel.mobi"
    ];
  };
  users.groups.music = {};

  systemd.tmpfiles.rules = [
    "d /music-chroot 0755 root root -"
    "d /music-chroot/music 0755 music music -"
  ];

  fileSystems."/music-chroot/music" = {
    device = "/music/uploads";
    fsType = "none";
    options = ["bind"];
  };

  services.openssh.extraConfig = ''
    Match User music
      ChrootDirectory /music-chroot
      ForceCommand internal-sftp
      AllowTcpForwarding no
  '';
  services.openssh.allowSFTP = true;
}