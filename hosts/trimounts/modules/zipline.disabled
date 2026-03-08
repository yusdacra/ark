{config, ...}:
let
  rootDomain = "ptr.pet";
  domain = "x.${rootDomain}";
in
{
  age.secrets.ziplineCfg = {
    file = ../../../secrets/ziplineCfg.age;
  };

  services.zipline = {
    enable = true;
    settings = {
      CORE_HOSTNAME = "127.0.0.1";
      CORE_PORT = 4488;
    };
    environmentFiles = [config.age.secrets.ziplineCfg.path];
    database.createLocally = true;
  };

  security.acme.certs.${rootDomain}.extraDomainNames = [domain];
    services.nginx.virtualHosts.${domain} = let
    localAddr = with config.services.zipline.settings; "http://${CORE_HOSTNAME}:${toString CORE_PORT}";
  in {
    useACMEHost = rootDomain;
    forceSSL = true;
    quic = true;
    kTLS = true;
    
    locations."/" = {
      proxyPass = localAddr;
      extraConfig = ''
        client_max_body_size 50M;
        proxy_request_buffering off;
      '';
    };
  };
}