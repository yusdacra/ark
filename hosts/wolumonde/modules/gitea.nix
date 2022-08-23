{config, ...}: {
  services.gitea = {
    enable = true;
    domain = "git.gaze.systems";
    rootUrl = "https://git.gaze.systems/";
    httpPort = 3001;
    settings = {
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
  };

  services.nginx.virtualHosts."git.gaze.systems" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:3001";
  };

  networking.firewall.allowedTCPPorts = [
    config.services.gitea.httpPort
  ];
}
