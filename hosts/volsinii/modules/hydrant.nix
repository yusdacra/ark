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
      HYDRANT_FIREHOSE_WORKERS = "128";
      HYDRANT_BACKFILL_CONCURRENCY_LIMIT = "256";
      HYDRANT_DB_WORKER_THREADS = "16";
      HYDRANT_CRAWLER_MAX_PENDING_REPOS = "10000";
      HYDRANT_PLC_URL = "https://plc.wtf,https://plc.directory";
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
}