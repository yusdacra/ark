{
  security.acme.certs."api.spool.klbr.net" = {};
  services.nginx.virtualHosts."api.spool.klbr.net" = {
    useACMEHost = "api.spool.klbr.net";
    forceSSL = true;
    kTLS = true;
    quic = true;
    locations."/".proxyPass = "http://chernobog:9889";
  };
}
