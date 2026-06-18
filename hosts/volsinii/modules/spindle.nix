{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  hostname = "ci.klbr.net";
in
{
  security.acme.certs.${hostname} = {};
  services.nginx.virtualHosts.${hostname} = {
    useACMEHost = hostname;
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://chernobog:7391";
      proxyWebsockets = true;
    };
  };
}
