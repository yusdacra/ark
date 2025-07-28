{
  lib,
  config,
  pkgs,
  terra,
  inputs,
  ...
}:
let
  format = pkgs.formats.yaml { };

  # A workaround generate a valid Headscale config accepted by Headplane when `config_strict == true`.
  settings = lib.recursiveUpdate config.services.headscale.settings {
    acme_email = "/dev/null";
    tls_cert_path = "/dev/null";
    tls_key_path = "/dev/null";
    policy.path = "/dev/null";
    oidc.client_secret_path = "/dev/null";
  };

  headscaleConfig = format.generate "headscale.yml" settings;

  domain = "plane.lan.gaze.systems";
  cfg = config.services.headplane.settings;
in
{
  imports = [ "${inputs.headplane}/nix/module.nix" ];

  services.headplane = {
    enable = true;
    package = terra.headplane;
    agent.enable = false;
    settings = {
      server = {
        host = "0.0.0.0";
        port = 4444;
        cookie_secret = lib.fixedWidthString 32 "0" "";
        cookie_secure = false;
      };
      headscale = {
        url = config.services.headscale.settings.server_url;
        config_path = "${headscaleConfig}";
        config_strict = true;
      };
      integration.proc.enabled = true;
      oidc = {
        issuer = config.services.pocket-id.settings.APP_URL;
        client_id = "2aae8944-94c3-42bb-8cb9-86ce85b1ee43";
        client_secret = "";
        token_endpoint_auth_method = "client_secret_post";
        headscale_api_key = "";
        disable_api_key_login = true;
        redirect_uri = "http://${domain}/admin/oidc/callback";
      };
    };
  };
  age.secrets.headplaneSecrets.file = ../../../secrets/headplaneSecrets.age;
  systemd.services.headplane.serviceConfig.EnvironmentFile = config.age.secrets.headplaneSecrets.path;

  services.headscale.settings.dns.extra_records = [
    {
      name = "plane.${config.services.headscale.settings.dns.base_domain}";
      type = "A";
      value = "100.64.0.2";
    }
  ];
  services.nginx.virtualHosts.${domain} = {
    quic = true;
    locations."=/".return = "301 /admin";
    locations."/".proxyPass = "http://localhost:${toString cfg.server.port}";
  };
}
