{
  lib,
  config,
  inputs,
  terra,
  ...
}:
let
  spindleCfg = config.services.tangled-spindle;
in
{
  imports = [
    "${inputs.tangled}/nix/modules/spindle.nix"
  ];

  services.tangled-spindle = {
    enable = true;
    package = terra.tangled-spindle;
    server = {
      listenAddr = "0.0.0.0:7391";
      hostname = "spindle.gaze.systems";
      owner = "did:plc:dfl62fgb7wtjj3fcbb72naae";
      secrets = {
        provider = "openbao";
        openbao.proxyAddr = "http://spindle.bao.lan.gaze.systems";
      };
    };
  };
  users.users.spindle = {
    group = "spindle";
    isSystemUser = true;
  };
  users.groups.spindle = { };
  users.groups.podman.members = [ "spindle" ];
  systemd.services.spindle = {
    after = lib.mkForce [ "network.target" "openbao-proxy-spindle.service" ];
    serviceConfig = {
      User = "spindle";
      Group = "spindle";
    };
  };

  security.acme.certs."gaze.systems".extraDomainNames = [spindleCfg.server.hostname];

  services.nginx.virtualHosts.${spindleCfg.server.hostname} = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://${spindleCfg.server.listenAddr}";
      proxyWebsockets = true;
    };
  };

  virtualisation.docker.enable = lib.mkForce false;
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };
}
