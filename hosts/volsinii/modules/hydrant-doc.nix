{ ... }:
let
  domain = "hydrant.gaze.systems";
in
{
  security.acme.certs."plc.gaze.systems".extraDomainNames = [domain];

  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "plc.gaze.systems";
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
