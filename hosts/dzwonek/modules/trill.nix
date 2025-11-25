{pkgs, inputs, ...}:
let
  rootDomain = "vpn.gaze.systems";
  domain = "trill.ptr.pet";
  pkg = pkgs.callPackage "${inputs.trill}/nix" rec {
    memos-modules = pkgs.callPackage "${inputs.trill}/nix/modules.nix" {};
    VITE_CLIENT_URI = "https://${domain}";
    VITE_OAUTH_CLIENT_ID = "${VITE_CLIENT_URI}/oauth-client-metadata.json";
    VITE_OAUTH_REDIRECT_URL = "${VITE_CLIENT_URI}/";
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
