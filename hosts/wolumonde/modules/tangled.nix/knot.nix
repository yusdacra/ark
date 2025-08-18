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

  age.secrets.tangledKnot.file = ../../../../secrets/tangledKnot.age;

  services.tangled-knot = {
    enable = true;
    package = terra.tangled-knot;
    gitUser = "git";
    motdFile = ./motd;
    server = {
      listenAddr = "0.0.0.0:7777";
      secretFile = config.age.secrets.tangledKnot.path;
      hostname = "knot.gaze.systems";
    };
  };

  security.acme.certs."gaze.systems".extraDomainNames = [knotCfg.server.hostname];

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
