{pkgs, terra, inputs, ...}:
{
  users.users.drop = {
    isSystemUser = true;
    group = "drop";
    home = "/var/lib/drop";
    createHome = true;
  };
  users.groups.drop = {};

  systemd.services.drop = {
    description = "drop";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    environment = {
      PORT = "8663";
      MAX_FILE_SIZE = "200000000";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${terra.drop}/bin/drop";
      Restart = "on-failure";
      RestartSec = "10s";
      StateDirectory = "drop";
      WorkingDirectory = "/var/lib/drop";
      User = "drop";
      Group = "drop";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = ["/var/lib/drop"];
    };
  };

  security.acme.certs."drop.klbr.net" = {};
  services.nginx.virtualHosts."drop.klbr.net" = {
    useACMEHost = "drop.klbr.net";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/".proxyPass = "http://127.0.0.1:8663";
    extraConfig = "client_max_body_size 200M;";
  };
}