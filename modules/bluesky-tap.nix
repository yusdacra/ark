{ config, lib, ... }:
let
  cfg = config.services.bluesky-tap;
in
{
  options.services.bluesky-tap = {
    enable = lib.mkEnableOption "bluesky network tap service";

    package = lib.mkOption {
      type = lib.types.package;
    };

    databaseUrl = lib.mkOption {
      type = lib.types.str;
      default = "sqlite:///var/lib/bluesky-tap/tap.db";
      description = "database connection string (sqlite or postgresql)";
      example = "postgresql://tap@/tap";
    };
    
    bind = lib.mkOption {
      type = lib.types.str;
      default = ":2480";
      description = "HTTP server address";
    };
    
    relayUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://relay1.us-east.bsky.network";
      description = "AT Protocol relay URL";
    };
    
    fullNetwork = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        track all repos on the entire network. 
        resource-intensive and takes days/weeks to complete backfill.
      '';
    };
    
    signalCollection = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "track all repos with at least one record in this collection";
      example = "app.bsky.actor.profile";
    };
    
    collectionFilters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "collection filters (wildcards accepted)";
      example = [ "app.bsky.feed.post" "app.bsky.graph.*" ];
    };
    
    metricsListen = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = ":8765";
      description = "address for metrics/pprof server (disabled if null)";
    };
    
    disableAcks = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "fire-and-forget mode, no client acks";
    };
    
    logLevel = lib.mkOption {
      type = lib.types.enum [ "debug" "info" "warn" "error" ];
      default = "info";
      description = "log verbosity";
    };
  };
  
  config = lib.mkIf cfg.enable {
    systemd.services.bluesky-tap = {
      description = "bluesky network tap firehose consumer";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      environment = {
        TAP_DATABASE_URL = cfg.databaseUrl;
        TAP_BIND = cfg.bind;
        TAP_RELAY_URL = cfg.relayUrl;
        TAP_FULL_NETWORK = lib.boolToString cfg.fullNetwork;
        TAP_DISABLE_ACKS = lib.boolToString cfg.disableAcks;
        TAP_LOG_LEVEL = cfg.logLevel;
      } // lib.optionalAttrs (cfg.signalCollection != null) {
        TAP_SIGNAL_COLLECTION = cfg.signalCollection;
      } // lib.optionalAttrs (cfg.collectionFilters != []) {
        TAP_COLLECTION_FILTERS = lib.concatStringsSep "," cfg.collectionFilters;
      } // lib.optionalAttrs (cfg.metricsListen != null) {
        TAP_METRICS_LISTEN = cfg.metricsListen;
      };
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/tap run";
        Restart = "on-failure";
        RestartSec = "10s";
        StateDirectory = "bluesky-tap";
        WorkingDirectory = "/var/lib/bluesky-tap";
        
        # create dedicated user instead of dynamic
        User = "bluesky-tap";
        Group = "bluesky-tap";
        
        # hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ "/var/lib/bluesky-tap" ];
      };
    };
    
    users.users.bluesky-tap = {
      isSystemUser = true;
      group = "bluesky-tap";
      home = "/var/lib/bluesky-tap";
    };
    users.groups.bluesky-tap = {};
  };
}
