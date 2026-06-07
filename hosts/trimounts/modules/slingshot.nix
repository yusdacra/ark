{
  terra,
  ...
}:

let
  domain = "sl.klbr.net";
  port = 8081;
  relayPort = 13579;
in
{
  users.users.slingshot = {
    isSystemUser = true;
    group = "slingshot";
    home = "/var/lib/slingshot";
  };
  users.groups.slingshot = { };

  systemd.services.slingshot = {
    description = "slingshot atproto record edge cache";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment = {
      RUST_BACKTRACE = "1";
      RUST_LOG = "info,slingshot=trace";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${terra.slingshot}/bin/slingshot \
          --jetstream ws://127.0.0.1:${toString relayPort}/subscribe \
          --cache-dir /var/lib/slingshot/cache \
          --bind 127.0.0.1:${toString port} \
          --record-cache-memory-mb 1024 \
          --record-cache-disk-gb 8 \
          --identity-cache-memory-mb 1024 \
          --identity-cache-disk-gb 8 \
          --collect-metrics \
          --bind-metrics 127.0.0.1:8765
      '';
      Restart = "on-failure";
      RestartSec = "10s";
      StateDirectory = "slingshot";
      WorkingDirectory = "/var/lib/slingshot";
      User = "slingshot";
      Group = "slingshot";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/slingshot" ];
      LimitNOFILE = 1048576;
    };
  };

  security.acme.certs.${domain} = { };
  services.nginx.virtualHosts.${domain} = {
    useACMEHost = domain;
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
}
