{ pkgs, ... }:
let
  port = "13580";
  inverterHost = "inverter.199-71-188-53.sslip.io";
  pdsHost = "pds-inverter.199-71-188-53.sslip.io";
  inverter = pkgs.rustPlatform.buildRustPackage {
    pname = "inverter";
    version = "0.1.0";
    src = ../inverter;
    cargoLock.lockFile = ../inverter/Cargo.lock;
  };
in
{
  users.users.inverter = {
    isSystemUser = true;
    group = "inverter";
    home = "/var/lib/inverter";
  };
  users.groups.inverter = { };
  users.users.pds-inverter = {
    isSystemUser = true;
    group = "pds-inverter";
    home = "/var/lib/pds-inverter";
  };
  users.groups.pds-inverter = { };


  systemd.services.inverter = {
    description = "durable AT Protocol PDS-to-relay inverter";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment = {
      INVERTER_LISTEN = "127.0.0.1:${port}";
      INVERTER_DATABASE_URL = "sqlite:///var/lib/inverter/events.sqlite?mode=rwc";
      INVERTER_PUBLIC_URL = "https://${inverterHost}";
      INVERTER_UPSTREAM_URL = "https://${pdsHost}";
      INVERTER_RELAY_URLS = "https://relay.klbr.net";
      RUST_LOG = "inverter=info,tower_http=info";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${inverter}/bin/inverter";
      EnvironmentFile = "/var/lib/inverter/environment";
      Restart = "on-failure";
      RestartSec = "3s";
      StateDirectory = "inverter";
      WorkingDirectory = "/var/lib/inverter";
      User = "inverter";
      Group = "inverter";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/inverter" ];
    };
  };
  systemd.services.pds-inverter = {
    description = "reference AT Protocol PDS with inverter push support";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "inverter.service" ];
    wants = [ "network-online.target" ];
    environment = {
      PDS_HOSTNAME = inverterHost;
      PDS_PORT = "2583";
      PDS_DATA_DIRECTORY = "/var/lib/pds-inverter";
      PDS_BLOBSTORE_DISK_LOCATION = "/var/lib/pds-inverter/blobs";
      PDS_INVITE_REQUIRED = "true";
      PDS_RATE_LIMITS_ENABLED = "false";
      PDS_INVERTER_URL = "https://${inverterHost}";
      PDS_INVERTER_CURSOR_LOCATION = "/var/lib/pds-inverter/inverter.cursor";
      LOG_ENABLED = "true";
      LOG_LEVEL = "info";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.nodejs_24}/bin/node /opt/atproto-inverter/run-pds.mjs";
      EnvironmentFile = "/var/lib/pds-inverter/environment";
      Restart = "on-failure";
      RestartSec = "3s";
      StateDirectory = "pds-inverter";
      WorkingDirectory = "/opt/atproto-inverter";
      User = "pds-inverter";
      Group = "pds-inverter";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/pds-inverter" ];
    };
  };


  security.acme.certs.${inverterHost} = { };
  services.nginx.virtualHosts.${inverterHost} = {
    useACMEHost = inverterHost;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${port}";
      proxyWebsockets = true;
    };
  };

  security.acme.certs.${pdsHost} = { };
  services.nginx.virtualHosts.${pdsHost} = {
    useACMEHost = pdsHost;
    forceSSL = true;
    locations."/".proxyPass = "http://127.0.0.1:2583";
    locations."/xrpc/com.atproto.sync.subscribeRepos" = {
      proxyPass = "http://127.0.0.1:2583";
      proxyWebsockets = true;
    };
  };
}
