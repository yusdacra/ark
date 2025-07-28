{ config, ... }:
let
  rootDomain = "gaze.systems";
  domain = "vpn.${rootDomain}";
in
{
  age.secrets.headscaleOidcSecret = {
    file = ../../../../secrets/headscaleOidcSecret.age;
    mode = "600";
    owner = config.services.headscale.user;
    group = config.services.headscale.group;
  };

  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 1111;
    settings = {
      server_url = "https://${domain}";
      policy = {
        mode = "file";
        path = ./acl.hujson;
      };
      dns = {
        base_domain = "lan.${rootDomain}";
        nameservers.global = [
          "1.1.1.1"
          "1.0.0.1"
          "9.9.9.9"
          "149.112.112.112"
        ];
      };
      oidc = {
        issuer = config.services.pocket-id.settings.APP_URL;
        client_id = "ba2c2024-f75f-49a2-a156-8593becfba28";
        client_secret_path = config.age.secrets.headscaleOidcSecret.path;
        pkce.enabled = true;
        only_start_if_oidc_is_available = true;
      };
    };
  };

  services.nginx.virtualHosts.${domain} = {
    useACMEHost = rootDomain;
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.headscale.port}";
      proxyWebsockets = true;
    };
  };
}
