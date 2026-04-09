{terra, ...}:
let
  rootDomain = "vpn.klbr.net";
  domain = "dysnomia.ptr.pet";
in
{
  security.acme.certs.${rootDomain}.extraDomainNames = [domain];
  services.nginx.virtualHosts.${domain} = {
    useACMEHost = rootDomain;
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      root = terra.dysnomia;
      tryFiles = "$uri $uri/ /index.html";
      extraConfig = ''
        add_header Cross-Origin-Embedder-Policy "require-corp";
        add_header Cross-Origin-Opener-Policy "same-origin";
      '';
    };
  };
}
