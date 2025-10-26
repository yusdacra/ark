{
  config,
  inputs,
  terra,
  ...
}:
let
  knotCfg = config.services.tangled-knot;
in
{
  imports = [
    "${inputs.tangled}/nix/modules/knot.nix"
  ];

  services.tangled-knot = {
    enable = true;
    package = terra.tangled-knot;
    gitUser = "git";
    motdFile = ./motd;
    server = {
      listenAddr = "0.0.0.0:7777";
      hostname = "knot.gaze.systems";
      owner = "did:plc:dfl62fgb7wtjj3fcbb72naae";
    };
  };

  security.acme.certs."gaze.systems".extraDomainNames = [ knotCfg.server.hostname ];

  services.nginx.virtualHosts.${knotCfg.server.hostname} = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://${knotCfg.server.listenAddr}";
      proxyWebsockets = true;
    };
  };
}
