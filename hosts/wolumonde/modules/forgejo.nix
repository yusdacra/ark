{pkgs, config, ...}: {
  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    lfs.enable = true;
    settings = {
      DEFAULT.APP_NAME = "meow :3";
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
    };
  };

  services.nginx.virtualHosts."git.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      extraConfig = ''
        client_max_body_size 1000m;
      '';
      proxyPass = "http://localhost${config.services.anubis.instances."forgejo".settings.BIND}";
    };
  };

  services.anubis.instances."forgejo" = {
    settings.BIND = ":6293";
    settings.BIND_NETWORK = "tcp";
    settings.TARGET = "http://localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}";
  };
}
