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
      session.COOKIE_SECURE = true;
      attachment = {
        MAX_SIZE = 50;
      };
      ui = {
        DEFAULT_SHOW_FULL_NAME = true;
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
      proxyPass = "http://localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}";
    };
  };
}
