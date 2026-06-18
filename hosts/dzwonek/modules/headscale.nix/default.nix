{ lib, config, ... }:
let
  rootDomain = "klbr.net";
  domain = "vpn.${rootDomain}";
in
{
  imports = [ ./acl.nix ];

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
    acl = let
      me = "90008@klbr.net";
      owner = "ana@nekomimi.pet";
    in {
      groups.admin = [me];
      tagOwners = {
        private-infra = [ "group:admin" ];
        other-infra = [ "group:admin" ];
      };
      hosts = {
        chernobog = "100.64.0.6";
        trimounts = "100.64.0.1";
        volsinii = "100.64.0.3";
      };
      sshRules = [
        {
          src = ["autogroup:member"];
          dst = ["autogroup:self"];
          users = ["autogroup:nonroot"];
        }
      ];
      rules = lib.mkBefore [
        {
          src = [ "group:admin" ];
          dst = [
            "tag:private-infra:*"
            "tag:other-infra:*"
          ];
        }
        {
          src = [ owner ];
          dst = ["${me}:*" "tag:private-infra:*"];
        }
        {
          src = [ me ];
          dst = [ "${owner}:*" ];
        }
        {
          src = [ "tag:private-infra" ];
          dst = [ "tag:other-infra:*" ];
        }
        {
          src = [ "tag:private-infra" ];
          dst = [ "tag:private-infra:*" ];
        }
        {
          src = [ "trimounts" "volsinii" ];
          dst = [ "chernobog:*" ];
        }
        {
          src = ["autogroup:member"];
          dst = ["autogroup:self:*"];
        }
        {
          src = [
            me owner
            "tag:private-infra"
          ];
          dst = [ "autogroup:internet:*" ];
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
        # issuer = "https://atlogin.net";
        # client_id = "ptr-pet-at-atlogin-net-headscale-v1";
        # client_secret_path = config.age.secrets.headscaleOidcSecret.path;
        # pkce.enabled = true;
        only_start_if_oidc_is_available = false;
      };
    };
  };

  # security.acme.certs.${rootDomain}.extraDomainNames = [domain];
  services.nginx.virtualHosts.${domain} = {
    useACMEHost = domain;
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.headscale.port}";
      proxyWebsockets = true;
    };
  };
}
