{pkgs, inputs, ...}:
{
  users.users.compare-plc = {
    isSystemUser = true;
    group = "compare-plc";
    home = "/var/lib/compare-plc";
    createHome = true;
  };
  users.groups.compare-plc = {};

  systemd.services.compare-plc = {
    description = "compare-plc";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bun}/bin/bun ${inputs.compare-plc}/server.ts";
      Restart = "on-failure";
      RestartSec = "10s";
      StateDirectory = "compare-plc";
      WorkingDirectory = "/var/lib/compare-plc";
      User = "compare-plc";
      Group = "compare-plc";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = ["/var/lib/compare-plc"];
    };
  };

  security.acme.certs."api.compare.plc.klbr.net" = {};
  services.nginx.virtualHosts."api.compare.plc.klbr.net" = {
    useACMEHost = "api.compare.plc.klbr.net";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/".proxyPass = "http://127.0.0.1:7331";
  };
}