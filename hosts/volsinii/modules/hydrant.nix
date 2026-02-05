{terra, ...}: {
  users.users.hydrant = {
    isSystemUser = true;
    group = "hydrant";
    home = "/var/lib/hydrant";
  };
  users.groups.hydrant = {};

  systemd.services.hydrant = {
    description = "hydrant ATURI indexer";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    environment = {
      HYDRANT_FULL_NETWORK = "true";
      HYDRANT_CACHE_SIZE = "1024";
      HYDRANT_BACKFILL_CONCURRENCY_LIMIT = "128";
      HYDRANT_NO_LZ4_COMPRESSION = "true";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${terra.hydrant}/bin/hydrant";
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
      ReadWritePaths = ["/var/lib/hydrant"];
    };
  };
}