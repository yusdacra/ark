{config, ...}: {
  services.gitea = {
    enable = true;
    lfs.enable = true;
    appName = "meow :3";
    settings = {
      server = {
        DOMAIN = "git.gaze.systems";
        ROOT_URL = "https://git.gaze.systems/";
        HTTP_PORT = 3001;
      };
      service = {
        DISABLE_REGISTRATION = false;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
      };
      session.COOKIE_SECURE = true;
      repository.MAX_CREATION_LIMIT = 0;
      oauth2_client = {
        ENABLE_AUTO_REGISTRATION = false;
        UPDATE_AVATAR = true;
      };
      attachment = {
        MAX_SIZE = 100;
      };
      ui = {
        DEFAULT_SHOW_FULL_NAME = true;
        DEFAULT_THEME = "edge-dark";
        THEMES = "edge-dark,gitea";
        THEME_COLOR_META_TAG = "#333644";
      };
    };
  };

  services.nginx.virtualHosts."git.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    locations."/" = {
      extraConfig = ''
        client_max_body_size 50m;
      '';
      proxyPass = "http://localhost:${toString config.services.gitea.settings.server.HTTP_PORT}";
    };
  };
}
