{config, ...}: {
  age.secrets.arpaCert = {
    file = ../../../secrets/arpaCert.age;
    mode = "600";
    owner = "nginx";
    group = "nginx";
  };
  age.secrets.arpaKey = {
    file = ../../../secrets/arpaKey.age;
    mode = "600";
    owner = "nginx";
    group = "nginx";
  };

  services.nginx.virtualHosts."9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa" = {
    forceSSL = true;
    sslCertificate = config.age.secrets.arpaCert.path;
    sslCertificateKey = config.age.secrets.arpaKey.path;
    locations."/" = {
      proxyPass = "http://localhost:${config.systemd.services.website.environment.PORT}";
    };
  };
}
