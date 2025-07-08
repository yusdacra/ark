{ config, inputs, ... }:
let
  cfg = config.services.tangled-knot;
in
{
  imports = [ inputs.tangled.nixosModules.knot ];

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

  services.nginx.virtualHosts.${cfg.server.hostname} = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/".proxyPass = "http://${cfg.server.listenAddr}";
  };
}
