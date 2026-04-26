{ terra, ... }:
let
  port = 8000;

  rootDomain = "klbr.net";
  domain = "bsky.${rootDomain}";
in {
  # users.users.slopview = {
  #   isSystemUser = true;
  #   group = "slopview";
  # };
  # users.groups.slopview = {};

  # systemd.services.slopview = {
  #   description = "slopview";
  #   wantedBy = ["multi-user.target"];
  #   after = ["network.target"];

  #   environment = {
  #     PORT = toString port;
  #     SEED_ACCOUNT = "did:plc:dfl62fgb7wtjj3fcbb72naae";
  #   };

  #   serviceConfig = rec {
  #     ExecStart = "${terra.slopview}/bin/appview";
  #     User = "slopview";
  #     Group = "slopview";
  #     StateDirectory = "slopview";
  #     WorkingDirectory = "%S/${StateDirectory}";
  #     Restart = "on-failure";
  #     RestartSec = "5s";
  #   };
  # };

  security.acme.certs.${rootDomain}.extraDomainNames = [domain];
  services.nginx.virtualHosts.${domain} = {
    useACMEHost = rootDomain;
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/".proxyPass = "http://chernobog:${toString port}";
  };
}
