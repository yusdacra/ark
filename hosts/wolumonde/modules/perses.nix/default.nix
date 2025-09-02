{
  pkgs,
  config,
  ...
}:
let
  domain = "dash.gaze.systems";
  port = 7412;
  user = "perses";

  provisionFolder = "provisioning";
  provisioningFolder = "${config.users.users.${user}.home}/${provisionFolder}";

  persesConfig = {
    database.file = {
      folder = config.users.users.${user}.home;
      extension = "json";
    };
    provisioning.folders = [ provisioningFolder ];
    security = {
      enable_auth = true;
      authentication = {
        providers = {
          enable_native = false;
          oidc = [
            {
              slug_id = "pocketid";
              name = "Pocket ID";
              client_id = "aa583db6-e03c-4490-853a-7f2b3e089fbe";
              issuer = config.services.pocket-id.settings.APP_URL;
              scopes = [ "openid profile email" ];
            }
          ];
        };
        disable_sign_up = false;
      };
      cookie = {
        same_site = "strict";
        secure = true;
      };
    };
  };
  persesConfigYaml = pkgs.writers.writeYAML "config.yaml" persesConfig;

  secrets = config.age.secrets;
in
{
  environment.systemPackages = [ pkgs.perses ];

  users.users.${user} = {
    isNormalUser = true;
    group = user;
    home = "/var/lib/${user}";
    createHome = true;
    uid = 1001;
  };
  users.groups.${user} = {
    gid = 976;
  };

  age.secrets.persesSecret = {
    file = ../../../../secrets/persesSecret.age;
    owner = user;
    group = user;
  };

  systemd.services.perses = {
    description = "perses";
    after = ["network.target" "pocket-id.service"];
    requires = ["pocket-id.service"];
    serviceConfig = {
      ExecStart = "${pkgs.perses}/bin/perses --config=${persesConfigYaml} --web.listen-address=:${toString port} --log.level=info";
      EnvironmentFile = secrets.persesSecret.path;
      WorkingDirectory = config.users.users.${user}.home;
    };
  };
  systemd.services.perses.preStart = ''
    rm -rf ${provisioningFolder} && mkdir -p ${provisioningFolder}
    cp -f ${./provision}/* ${provisioningFolder}
  '';

  security.acme.certs."gaze.systems".extraDomainNames = [domain];
  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "gaze.systems"; # TODO: write a module to define vhosts for subdomains
    quic = true;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString port}";
    };
  };

  # scrape perses metrics
  services.victoriametrics.prometheusConfig.scrape_configs = [
    {
      job_name = "perses";
      metrics_path = "/metrics";
      static_configs = [ { targets = [ "localhost:${toString port}" ]; } ];
    }
  ];
}
