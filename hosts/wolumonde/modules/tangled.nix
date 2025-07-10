{ lib, config, inputs, ... }:
let
  knotCfg = config.services.tangled-knot;
  spindleCfg = config.services.tangled-spindle;
in
{
  imports = [ inputs.tangled.nixosModules.knot inputs.tangled.nixosModules.spindle ];

  age.secrets.tangledKnot.file = ../../../secrets/tangledKnot.age;

  services.tangled-knot = {
    enable = true;
    gitUser = "git";
    server = {
      listenAddr = "0.0.0.0:7777";
      secretFile = config.age.secrets.tangledKnot.path;
      hostname = "knot.gaze.systems";
    };
  };

  services.nginx.virtualHosts.${knotCfg.server.hostname} = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://${knotCfg.server.listenAddr}";
      extraConfig = ''
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header id $request_id;
      '';
    };
  };

  services.tangled-spindle = {
    enable = true;
    server = {
      listenAddr = "0.0.0.0:7391";
      hostname = "spindle.gaze.systems";
      owner = "did:plc:dfl62fgb7wtjj3fcbb72naae";
    };
  };
  users.users.spindle = {
    group = "spindle";
    isSystemUser = true;
  };
  users.groups.spindle = {};
  users.groups.podman.members = ["spindle"];
  systemd.services.spindle = {
    after = lib.mkForce ["network.target"];
    serviceConfig = {
      User = "spindle";
      Group = "spindle";
    };
  };

  services.nginx.virtualHosts.${spindleCfg.server.hostname} = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://${spindleCfg.server.listenAddr}";
      extraConfig = ''
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header id $request_id;
      '';
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
