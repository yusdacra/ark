{ terra, config, ... }:
let
  domain = "tap.gaze.systems";
  cfg = config.services.bluesky-tap;
in
{
  imports = [../../../modules/bluesky-tap.nix];

  services.bluesky-tap = {
    enable = true;
    package = terra.bluesky-tap;
    fullNetwork = true;
    databaseUrl = "postgresql://bluesky-tap@/bluesky-tap";
    bind = "127.0.0.1:2480";
    metricsListen = "127.0.0.1:8765";
    logLevel = "info";
  };

  # setup postgres
  services.postgresql = {
    enable = true;
    ensureDatabases = ["bluesky-tap"];
    ensureUsers = [{
      name = "bluesky-tap";
      ensureDBOwnership = true;
    }];
  };

  # nginx reverse proxy
  services.nginx.virtualHosts.${domain} = {
    useACMEHost = domain;
    forceSSL = true;
    quic = true;
    kTLS = true;
    
    # locations."/" = {
    #   proxyPass = "http://${cfg.bind}";
    #   proxyWebsockets = true;
    # };
  };
}