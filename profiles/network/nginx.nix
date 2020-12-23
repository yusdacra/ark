{ ... }: {
  # services.nginx = {
  #   enable = true;
  #   enableReload = true;
  #   statusPage = true;
  #   recommendedGzipSettings = true;
  #   recommendedOptimisation = true;
  #   recommendedProxySettings = true;
  #   recommendedTlsSettings = true;
  #   virtualHosts."yusdacras-host.ydns.eu" = {
  #     # addSSL = true;
  #     # enableACME = true;
  #     listen = [
  #       { addr = "0.0.0.0"; port = 8080; }
  #       { addr = "[::]"; port = 8080; }
  #       # { addr = "0.0.0.0"; port = 8081; ssl = true; }
  #     ];
  #     locations = {
  #       "/matrix" = { proxyPass = "http://localhost:8000"; };
  #       "/page" = {
  #         root = "/var/www/yusdacras-host";
  #       };
  #     };
  #   };
  # };

  # security.acme = {
  #   acceptTerms = true;
  #   certs = {
  #     "yusdacras-host.ydns.eu".email = "y.bera003.06@protonmail.com";
  #   };
  # };

  networking.firewall.allowedTCPPorts = [ 8000 8448 ];
}
