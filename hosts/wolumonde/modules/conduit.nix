{config, pkgs, ...}:
let
  wellKnownFileClient =
    pkgs.writeText "client" (
      builtins.toJSON
      { "m.homeserver"."base_url" = "https://matrix.gaze.systems"; }
    );
  wellKnownFileServer =
    pkgs.writeText "server"
    (builtins.toJSON { "m.server" = "matrix.gaze.systems:443"; });
in
{
  services.matrix-conduit = {
    enable = true;
    settings.global = {
      server_name = "gaze.systems";
      max_request_size = 1000 * 1000 * 20;
      allow_registration = true;
      allow_federation = true;
      trusted_servers = ["matrix.org" "nixos.dev" "conduit.rs"];
      address = "::1";
      port = 6167;
    };
  };

  services.nginx.virtualHosts."matrix.gaze.systems" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass =
      "http://localhost:${toString config.services.matrix-conduit.settings.global.port}";
  };
  services.nginx.virtualHosts."gaze.systems" = {
    locations."/.well-known/matrix/client".extraConfig = ''
      alias ${wellKnownFileClient}
    '';
    locations."/.well-known/matrix/server".extraConfig = ''
      alias ${wellKnownFileServer}
    '';
  };
}
