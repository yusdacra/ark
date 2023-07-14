{
  config,
  pkgs,
  inputs,
  ...
}: let
  _wellKnownFileClient = pkgs.writeText "client" (
    builtins.toJSON
    {
      "m.homeserver"."base_url" = "https://matrix.gaze.systems";
      "org.matrix.msc3575.proxy"."url" = "https://matrix.gaze.systems";
    }
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
    package = inputs.conduit.packages.${pkgs.system}.default;
    settings.global = {
      server_name = "gaze.systems";
      max_request_size = 1000 * 1000 * 20;
      allow_registration = false;
      allow_federation = true;
      trusted_servers = ["matrix.org" "nixos.dev" "conduit.rs"];
      address = "::1";
      port = 6167;
      database_backend = "rocksdb";
    };
  };

  services.nginx.virtualHosts."matrix.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:${toString config.services.matrix-conduit.settings.global.port}";
  };
  services.nginx.virtualHosts."gaze.systems" = {
    locations."/.well-known/matrix/".extraConfig = ''
      add_header content-type application/json;
      add_header access-control-allow-origin *;
      alias ${wellKnownFiles}/;
    '';
  };
}
