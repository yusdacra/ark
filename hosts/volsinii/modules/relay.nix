{ terra, ... }:
let
  port = "13579";
  pkg = terra.hydrant.overrideAttrs (old: {
    cargoBuildNoDefaultFeatures = true;
    cargoBuildFeatures = [ "relay" ];
    doCheck = false;
  });
in
{
  users.users.hydrant = {
    isSystemUser = true;
    group = "hydrant";
    home = "/var/lib/hydrant";
  };
  users.groups.hydrant = { };

  systemd.services.hydrant = {
    description = "hydrant atproto relay";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      HYDRANT_API_BIND = "0.0.0.0:${port},[::]:${port}";
      HYDRANT_CURSOR_SAVE_INTERVAL = "1sec";
      HYDRANT_SEED_HOSTS = "https://relay.bas.sh,https://bsky.network";
      HYDRANT_PLC_URL = "https://plc.directory";
      HYDRANT_DATA_COMPRESSION = "zstd";
      HYDRANT_JOURNAL_COMPRESSION = "zstd";
      HYDRANT_RATE_TIERS = "default:5000/10.0/18000000/432000000/10000000";
      HYDRANT_EPHEMERAL = "true";
      HYDRANT_EPHEMERAL_TTL = "1d";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkg}/bin/hydrant";
      Restart = "on-failure";
      RestartSec = "10s";
      StateDirectory = "hydrant";
      WorkingDirectory = "/var/lib/hydrant";
      User = "hydrant";
      Group = "hydrant";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/hydrant" ];
      LimitNOFILE = 1048576;
    };
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
  ];

  security.acme.certs."plc.klbr.net".extraDomainNames = [ "relay.klbr.net" ];
  services.nginx.virtualHosts."relay.klbr.net" = {
    useACMEHost = "plc.klbr.net";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."=/".proxyPass = "http://localhost:${port}";
    locations."/xrpc" = {
      proxyPass = "http://localhost:${port}";
      proxyWebsockets = true;
    };
    locations."/_health".proxyPass = "http://localhost:${port}";
  };
}
