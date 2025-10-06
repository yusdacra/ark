{ lib, config, ... }:
let
  rootDomain = "gaze.systems";
  domain = "vpn.${rootDomain}";
in
{
  imports = [./acl.nix];

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
    acl = {
      groups.admin = ["90008@gaze.systems"];
      tagOwners = {
        private-infra = ["group:admin"];
        other-infra = ["group:admin"];
      };
      hosts = {
        chernobog = "100.64.0.9";
        wolumonde = "100.64.0.2";
        higashi = "100.64.0.5";
      };
      rules = lib.mkBefore [
        {
          src = ["group:admin"];
          dst = ["tag:private-infra:*" "tag:other-infra:*"];
        }
        {
          src = ["tag:private-infra"];
          dst = ["tag:other-infra:*"];
        }
        {
          src = ["wolumonde"];
          dst = ["chernobog:*"];
        }
        {
          src = ["90008@gaze.systems"];
          dst = ["90008@gaze.systems:*"];
        }
        {
          src = ["90008@gaze.systems" "tag:private-infra"];
          dst = ["autogroup:internet:*"];
        }
        {
          src = ["ellite@ellite.dev"];
          dst = ["chernobog:8463"];
        }
      ];
    };
    settings = {
      server_url = "https://${domain}";
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

  security.acme.certs."gaze.systems".extraDomainNames = [domain];
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
