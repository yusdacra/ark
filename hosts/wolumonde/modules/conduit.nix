{
  config,
  pkgs,
  ...
}: let
  _wellKnownFileClient = pkgs.writeText "client" (
    builtins.toJSON
    {"m.homeserver"."base_url" = "https://matrix.gaze.systems";}
  );
  _wellKnownFileServer =
    pkgs.writeText "server"
    (builtins.toJSON {"m.server" = "matrix.gaze.systems:443";});
  wellKnownFiles = pkgs.runCommand "well-known" {} ''
    mkdir -p $out
    cp ${_wellKnownFileServer} $out/server
    cp ${_wellKnownFileClient} $out/client
  '';
in {
  services.matrix-conduit = {
    enable = true;
    package = pkgs.matrix-conduit.overrideAttrs (old: rec {
      name = "${old.pname}-${version}";
      version = "147f2752";
      src = pkgs.fetchFromGitLab {
        owner = "famedly";
        repo = "conduit";
        rev = "147f27521c0d7dbc32d39ec1d8da6cd00008f23c";
        sha256 = "sha256-j469Zh8zyqJNWz7q6gjRu1Khk9y6Xbb52SpxzNjADW8=";
      };
    });
    settings.global = {
      server_name = "gaze.systems";
      max_request_size = 1000 * 1000 * 20;
      allow_registration = false;
      allow_federation = true;
      trusted_servers = ["matrix.org" "nixos.dev" "conduit.rs"];
      address = "::1";
      port = 6167;
    };
  };

  services.nginx.virtualHosts."matrix.gaze.systems" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:${toString config.services.matrix-conduit.settings.global.port}";
  };
  services.nginx.virtualHosts."gaze.systems" = {
    locations."/.well-known/matrix/".extraConfig = ''
      add_header content-type application/json;
      alias ${wellKnownFiles}/;
    '';
  };
}
