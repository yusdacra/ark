{config, lib, ...}: let
  cfg = config.services.unbound.settings;
in {
  services.unbound = {
    enable = true;
    enableRootTrustAnchor = false;
    resolveLocalQueries = false;
    checkconf = lib.mkForce true;
    settings = {
      server = {
        interface = [ "0.0.0.0" ];
        port = 7272;

        access-control = [
          "0.0.0.0/0 refuse" # lets explicitly refuse any queries
          "100.84.0.0/16 allow" # only allow queries from netbird
        ];

        hide-identity = true;
        hide-version = true;
        harden-glue = true;
        harden-referral-path = true;
        use-caps-for-id = true;

        ratelimit = 10;
        ratelimit-slabs = 4;
        ratelimit-size = "4m";

        unwanted-reply-threshold = 10000;
        do-not-query-localhost = true;
        deny-any = true;

        prefetch = true;
        prefetch-key = true;
      };
      forward-zone = [
        {
          name = ".";
          forward-addr = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        }
      ];
    };
  };
  networking.firewall = {
    allowedTCPPorts = [cfg.server.port];
    allowedUDPPorts = [cfg.server.port];
  };
}
