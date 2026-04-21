{ ... }:
let
  rootDomain = "klbr.net";
  domain = "hydrant.${rootDomain}";
in
{
  security.acme.certs."plc.${rootDomain}".extraDomainNames = [domain];
  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "plc.${rootDomain}";
    forceSSL = true;
    quic = true;
    kTLS = true;
    root = "/www/hydrant";
    locations."/" = {
      tryFiles = "$uri $uri/ =404";
    };
    locations."= /" = {
      return = "301 /hydrant/index.html";
    };
  };
}
