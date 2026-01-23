{terra, ...}: {
  users.users.aturlist = {
    isSystemUser = true;
    group = "aturlist";
    home = "/var/lib/aturlist";
  };
  users.groups.aturlist = {};

  systemd.services.aturlist = {
    description = "aturlist ATURI indexer";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${terra.aturlist}/bin/aturlist";
      Restart = "on-failure";
      RestartSec = "10s";
      StateDirectory = "aturlist";
      WorkingDirectory = "/var/lib/aturlist";
      User = "aturlist";
      Group = "aturlist";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = ["/var/lib/aturlist"];
    };
  };
}