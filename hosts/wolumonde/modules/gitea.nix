{config, ...}: {
  services.gitea = {
    enable = true;
    settings = {
      server = {
        DOMAIN = "git.gaze.systems";
        ROOT_URL = "https://git.gaze.systems/";
        HTTP_PORT = 3001;
      };
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
  };

  services.nginx.virtualHosts."git.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:${toString config.services.gitea.settings.server.HTTP_PORT}";
  };
}
