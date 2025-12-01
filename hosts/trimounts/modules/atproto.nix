{ pkgs, lib, ... }:
let
  getFileType = name: if lib.hasSuffix ".json" name then "application/json" else "text/plain";
  mkWellKnownCfg = files: {
    quic = true;
    kTLS = true;
    locations = (
      lib.mapAttrs' (name: file: {
        name = "=/.well-known/${name}";
        value = {
          extraConfig = ''
            alias ${file};
            add_header access-control-allow-origin *;
            default_type ${getFileType name};
          '';
        };
      }) files
    );
  };
  mkDidWebCfg = domain: {
    "${domain}" =
      (mkWellKnownCfg {
        "did.json" = ../../../secrets/${domain}.did;
        "atproto-did" = pkgs.writeText "server" "did:web:${domain}";
      })
      // (lib.optionalAttrs (lib.hasSuffix "gaze.systems" domain) {
        useACMEHost = "gaze.systems";
        forceSSL = true;
        quic = true;
        kTLS = true;
      });
  };
  guestbookDid = "guestbook.gaze.systems";
in
{
  security.acme.certs."gaze.systems".extraDomainNames = [guestbookDid];
  services.nginx.virtualHosts = mkDidWebCfg guestbookDid;
}
