{
  config,
  lib,
  pkgs,
  ...
}:
let
  port = 8945;
  secrets = config.age.secrets;
  cfgFile = pkgs.writeText "openbao-proxy-spindle-config.hcl" (
    lib.replaceStrings
      [
        "%role_id%"
        "%secret_id%"
        "%vault_address%"
        "%listener_port%"
        "%name%"
      ]
      [
        secrets.spindleOpenbaoRoleId.path
        secrets.spindleOpenbaoSecretId.path
        config.services.openbao.settings.api_addr
        (toString port)
        name
      ]
      (lib.fileContents ./config.hcl)
  );
  domain = "spindle.bao.lan.gaze.systems";
  name = "openbao-proxy-spindle";
in
{
  age.secrets.spindleOpenbaoRoleId = {
    file = ../../../../../secrets/spindleOpenbaoRoleId.age;
    mode = "600";
    owner = name;
    group = name;
  };
  age.secrets.spindleOpenbaoSecretId = {
    file = ../../../../../secrets/spindleOpenbaoSecretId.age;
    mode = "600";
    owner = name;
    group = name;
  };

  users.users.${name} = {
    isSystemUser = true;
    group = name;
  };
  users.groups.${name} = {
    members = [ name ];
  };

  systemd.services.${name} = {
    description = "OpenBao Proxy with Auto-Auth for tangled spindle";
    after = [ "openbao.service" ];
    before = [ "spindle.service" ];
    requires = [ "openbao.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.openbao}/bin/bao proxy -config=${cfgFile}";
      Restart = "on-failure";
      RestartSec = "5";
      LimitNOFILE = "65536";
      User = name;
      Group = name;
      RuntimeDirectory = name;
      RuntimeDirectoryMode = 0700;
      StateDirectory = name;
      StateDirectoryMode = 0700;
      ProcSubset = "pid";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "@resources"
        "~@privileged"
      ];
    };
  };

  services.headscale.settings.dns.extra_records = [
    {
      name = domain;
      type = "A";
      value = "100.64.0.2";
    }
  ];
  services.nginx.virtualHosts.${domain} = {
    quic = true;
    locations."/".proxyPass = "http://127.0.0.1:${toString port}";
  };
}
