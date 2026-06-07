{pkgs, inputs, ...}:
let
  rootDomain = "vpn.klbr.net";
  domain = "nucleus.ptr.pet";
  pkg = pkgs.callPackage "${inputs.nucleus}/nix" {
    nucleus-modules = (pkgs.callPackage "${inputs.nucleus}/nix/modules.nix" {}).overrideAttrs (old: {
      outputHash = "sha256-RbH5PfV4wa2lva49SbrDX5SI870nmY1IbgQjho6U2/0=";
    });
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
