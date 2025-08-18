{
  pkgs,
  lib,
  config,
  ...
}:
let
  forgejoCfg = config.services.forgejo.settings;
  anubisCfg = config.services.anubis.instances."forgejo".settings;
in
{
  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    lfs.enable = true;
    settings = {
      DEFAULT.APP_NAME = "awruff ^^";
      server = {
        DOMAIN = "git.gaze.systems";
        ROOT_URL = "https://git.gaze.systems/";
        HTTP_PORT = 9008;
      };
      service = {
        DISABLE_REGISTRATION = true;
      };
      security.REVERSE_PROXY_TRUSTED_PROXIES = "127.0.0.0/8,::1/128";
      session.COOKIE_SECURE = true;
      ui = {
        DEFAULT_SHOW_FULL_NAME = true;
        DEFAULT_THEME = "edge-dark";
        THEMES = "edge-dark,forgejo-dark";
        THEME_COLOR_META_TAG = "#333644";
      };
      "ui.meta" = {
        DESCRIPTION = "nyan? arf!!!! :3";
      };
      metrics.ENABLED = true;
    };
  };

  # copy custom data stuff
  systemd.services.forgejo.preStart =
    let
      customDir = "${config.services.forgejo.stateDir}/custom";
      getCustomDir = name: "${customDir}/${name}";
      makeCopyCommand = dir: ''
        mkdir -p ${customDir}
        rm -rf ${getCustomDir dir}
        cp -r --no-preserve=mode,ownership ${./${dir}} ${getCustomDir dir}
      '';
    in
    lib.concatMapStrings makeCopyCommand [
      "templates"
      "public"
    ];

  security.acme.certs."gaze.systems".extraDomainNames = [forgejoCfg.server.DOMAIN];
  services.nginx.virtualHosts.${forgejoCfg.server.DOMAIN} = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    # disallow metrics for public
    locations."/metrics".return = "403";
    locations."/" = {
      extraConfig = ''
        client_max_body_size 1000m;
      '';
      proxyPass = "http://localhost${anubisCfg.BIND}";
    };
  };

  services.anubis.instances."forgejo".settings = {
    BIND = ":6293";
    BIND_NETWORK = "tcp";
    METRICS_BIND = ":9090";
    METRICS_BIND_NETWORK = "tcp";
    TARGET = "http://localhost:${toString forgejoCfg.server.HTTP_PORT}";
    WEBMASTER_EMAIL = "90008@gaze.systems";
    SERVE_ROBOTS_TXT = true;
    OG_PASSTHROUGH = true;
    DIFFICULTY = 4;
  };

  # scrape forgejo metrics
  services.victoriametrics.prometheusConfig.scrape_configs = [
    {
      job_name = "forgejo";
      metrics_path = "/metrics";
      static_configs = [ { targets = [ "localhost:${toString forgejoCfg.server.HTTP_PORT}" ]; } ];
    }
    {
      job_name = "anubis_forgejo";
      metrics_path = "/metrics";
      static_configs = [ { targets = [ "localhost${anubisCfg.METRICS_BIND}" ]; } ];
    }
  ];
}
