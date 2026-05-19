{
  terra,
  ...
}:
let
  domain = "bobbin.klbr.net";
  bobbinPort = 8090;
  hydrantPort = 13010;
  slingshotPort = 8081;
  hydrantPkg = terra.hydrant.overrideAttrs (old: {
    doCheck = false;
  });
in
{
  users.users.bobbin = {
    isSystemUser = true;
    group = "bobbin";
    home = "/var/lib/bobbin";
  };
  users.groups.bobbin = { };

  users.users.hydrant-bobbin = {
    isSystemUser = true;
    group = "hydrant-bobbin";
    home = "/var/lib/hydrant-bobbin";
  };
  users.groups.hydrant-bobbin = { };

  systemd.services.hydrant-bobbin = {
    description = "hydrant atproto relay for bobbin";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "hydrant.service"
      "allegedly.service"
    ];
    wants = [
      "network-online.target"
      "hydrant.service"
      "allegedly.service"
    ];
    environment = {
      HYDRANT_API_BIND = "127.0.0.1:${toString hydrantPort}";
      HYDRANT_PLC_URL = "http://127.0.0.1:8000";
      HYDRANT_RELAY_HOSTS = "http://127.0.0.1:13579";
      HYDRANT_FILTER_SIGNALS = "sh.tangled.actor.profile,sh.tangled.feed.reaction,sh.tangled.feed.star,sh.tangled.git.refUpdate,sh.tangled.graph.follow,sh.tangled.graph.vouch,sh.tangled.knot,sh.tangled.knot.member,sh.tangled.label.definition,sh.tangled.label.op,sh.tangled.pipeline,sh.tangled.pipeline.status,sh.tangled.publicKey,sh.tangled.repo,sh.tangled.repo.artifact,sh.tangled.repo.collaborator,sh.tangled.repo.issue,sh.tangled.repo.issue.comment,sh.tangled.repo.issue.state,sh.tangled.repo.pull,sh.tangled.repo.pull.comment,sh.tangled.repo.pull.status,sh.tangled.spindle,sh.tangled.spindle.member,sh.tangled.string";
      HYDRANT_FILTER_COLLECTIONS = "sh.tangled.*";
      HYDRANT_VERIFY_SIGNATURES = "none";
      HYDRANT_REPO_FETCH_TIMEOUT = "1h";
      HYDRANT_FIREHOSE_WORKERS = "24";
      HYDRANT_BACKFILL_CONCURRENCY_LIMIT = "64";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${hydrantPkg}/bin/hydrant";
      Restart = "on-failure";
      RestartSec = "10s";
      StateDirectory = "hydrant-bobbin";
      WorkingDirectory = "/var/lib/hydrant-bobbin";
      User = "hydrant-bobbin";
      Group = "hydrant-bobbin";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/hydrant-bobbin" ];
      LimitNOFILE = 1048576;
    };
  };

  systemd.services.bobbin = {
    description = "bobbin tangled graph index";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "hydrant-bobbin.service"
      "slingshot.service"
    ];
    wants = [
      "network-online.target"
      "hydrant-bobbin.service"
      "slingshot.service"
    ];
    environment = {
      BOBBIN_BIND = "127.0.0.1:${toString bobbinPort}";
      BOBBIN_HYDRANT_URL = "http://127.0.0.1:${toString hydrantPort}";
      BOBBIN_SLINGSHOT_URL = "http://127.0.0.1:${toString slingshotPort}";
      # BOBBIN_LOG_FORMAT = "json";
      BOBBIN_LOG = "info";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${terra.bobbin}/bin/bobbin";
      Restart = "on-failure";
      RestartSec = "10s";
      StateDirectory = "bobbin";
      WorkingDirectory = "/var/lib/bobbin";
      User = "bobbin";
      Group = "bobbin";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/bobbin" ];
      LimitNOFILE = 1048576;
    };
  };

  security.acme.certs.${domain} = { };
  services.nginx.virtualHosts.${domain} = {
    useACMEHost = domain;
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString bobbinPort}";
      proxyWebsockets = true;
    };
  };
}
