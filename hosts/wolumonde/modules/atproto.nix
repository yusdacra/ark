{pkgs, lib, ...}: let
  mkFileCopy = name: file: "cp ${file} $out/${name}";
  mkWellKnownDir = files: pkgs.runCommand "well-known" {} ''
    mkdir -p $out
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList mkFileCopy files)}
  '';
  mkWellKnownCfg = files: {
    locations."/.well-known/".extraConfig = ''
      add_header content-type text/plain;
      add_header access-control-allow-origin *;
      alias ${mkWellKnownDir files}/;
    '';
  };
  mkDidWebCfg = domain: {
    "${domain}" = (mkWellKnownCfg {
      "did.json" = ../../../secrets/${domain}.did;
      "atproto-did" = pkgs.writeText "server" "did:web:${domain}";
    }) // (lib.optionalAttrs (lib.hasSuffix "gaze.systems" domain) {
      useACMEHost = "gaze.systems";
      forceSSL = true;
    });
  };
in {
  services.nginx.virtualHosts = {
    "gaze.systems" = (mkWellKnownCfg {
      "atproto-did" = pkgs.writeText "server" "did:plc:dfl62fgb7wtjj3fcbb72naae";
    }) // {
      useACMEHost = "gaze.systems";
      forceSSL = true;
    };
    # "9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa" = mkWellKnownCfg {
    #   "atproto-did" = pkgs.writeText "server" "did:plc:dfl62fgb7wtjj3fcbb72naae";
    # };
  } // (mkDidWebCfg "dawn.gaze.systems")
  // (mkDidWebCfg "guestbook.gaze.systems");
}
