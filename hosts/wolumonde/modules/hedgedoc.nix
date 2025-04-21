{config, ...}: {
  services.hedgedoc = {
    enable = true;
    settings = {
      port = 3333;
      domain = "doc.gaze.systems";
      protocolUseSSL = true;
      allowEmailRegister = false;
      allowAnonymous = false;
      allowAnonymousEdits = true;
      allowFreeURL = true;
      requireFreeURLAuthentication = true;
    };
  };

  services.nginx.virtualHosts."doc.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/".proxyPass = "http://${config.services.hedgedoc.settings.host}:${toString config.services.hedgedoc.settings.port}";
  };
}
