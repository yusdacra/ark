{ terra, ... }:
{
  networking.firewall.allowedTCPPorts = [ 8317 ];

  systemd.tmpfiles.rules = [
    "d /var/lib/cliproxy 0700 dawn users -"
    "d /var/lib/cliproxy/auths 0700 dawn users -"
    "d /var/lib/cliproxy/logs 0700 dawn users -"
  ];

  systemd.services.cliproxyapi = {
    description = "CLIProxyAPI";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "dawn";
      Group = "users";
      WorkingDirectory = "/var/lib/cliproxy";
      ExecStart = "${terra.cliproxyapi}/bin/cli-proxy-api -config /var/lib/cliproxy/config.yaml";
      Restart = "on-failure";
      RestartSec = 5;
      NoNewPrivileges = true;
      PrivateTmp = true;
    };
  };
}
