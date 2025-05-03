{ pkgs, lib, ... }:
let
  getFileType = name: if lib.hasSuffix ".json" name then "application/json" else "text/plain";
  mkWellKnownCfg = files: {
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
in
{
  services.nginx.virtualHosts =
    {
      "gaze.systems" =
        (mkWellKnownCfg {
          "atproto-did" = pkgs.writeText "server" "did:plc:dfl62fgb7wtjj3fcbb72naae";
        })
        // {
          useACMEHost = "gaze.systems";
          forceSSL = true;
          quic = true;
          kTLS = true;
        };
      # "9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa" = mkWellKnownCfg {
      #   "atproto-did" = pkgs.writeText "server" "did:plc:dfl62fgb7wtjj3fcbb72naae";
      # };
    }
    // (mkDidWebCfg "dawn.gaze.systems")
    // (mkDidWebCfg "guestbook.gaze.systems");
  # // (mkDidWebCfg "9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa");
}
