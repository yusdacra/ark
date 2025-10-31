{pkgs, inputs, ...}:
let
  rootDomain = "vpn.gaze.systems";
  domain = "nucleus.ptr.pet";
  pkg = pkgs.callPackage "${inputs.nucleus}/nix" {
    nucleus-modules = pkgs.callPackage "${inputs.nucleus}/nix/modules.nix" {};
    PUBLIC_DOMAIN = "https://${domain}";
  };
in
{
  security.acme.certs.${rootDomain}.extraDomainNames = [domain];
  services.nginx.virtualHosts.${domain} = {
    useACMEHost = rootDomain;
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      root = pkg;
      tryFiles = "$uri $uri/ /index.html";
    };
  };
}
