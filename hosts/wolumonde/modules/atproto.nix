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
  mkHandleCfg =
    rootDomain: did:
    (mkWellKnownCfg {
      "atproto-did" = pkgs.writeText "server" did;
    })
    // {
      useACMEHost = rootDomain;
      forceSSL = true;
      quic = true;
      kTLS = true;
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
  dawnDid = "dawn.gaze.systems";
  guestbookDid = "guestbook.gaze.systems";
in
{
  security.acme.certs."gaze.systems".extraDomainNames = [
    dawnDid
    guestbookDid
    "drew.gaze.systems"
    "test.gaze.systems"
    "eris.gaze.systems"
  ];
  services.nginx.virtualHosts = {
    "test.gaze.systems" = mkHandleCfg "gaze.systems" "did:web:dawn.gaze.systems";
    "poor.dog" = mkHandleCfg "poor.dog" "did:plc:dfl62fgb7wtjj3fcbb72naae";
    "ptr.pet" = mkHandleCfg "ptr.pet" "did:plc:dfl62fgb7wtjj3fcbb72naae";
    "nil.ptr.pet" = mkHandleCfg "ptr.pet" "did:plc:dumbmutttrskde4ibwbnbike";
    "june.ptr.pet" = mkHandleCfg "ptr.pet" "did:plc:y3z2rr7q5rywu4fjn3fmfyop";
    "drew.gaze.systems" = mkHandleCfg "gaze.systems" "did:plc:vo6ie3kd6xvpjlof4pnb2zzp";
    "eris.gaze.systems" = mkHandleCfg "gaze.systems" "did:plc:bxjnsrfzozl365rsdo5yvuz5";
  }
  // (mkDidWebCfg dawnDid)
  // (mkDidWebCfg guestbookDid);
  # // (mkDidWebCfg "9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa");
}
