{ pkgs, terra, config, ... }:
let
  domain = "dash.gaze.systems";
  port = 7412;
  user = "perses";

  provisionFolder = "provisioning";

  persesConfig = {
    database.file = {
      folder = "/perses";
      extension = "json";
    };
    provisioning.folders = [ "/perses/${provisionFolder}" ];
    security = {
      enable_auth = true;
      authentication = {
        providers.oidc = [{
          slug_id = "pocketid";
          name = "Pocket ID";
          client_id = "aa583db6-e03c-4490-853a-7f2b3e089fbe";
          issuer = config.services.pocket-id.settings.APP_URL;
          scopes = ["openid profile email"];
        }];
        disable_sign_up = true;
      };
      cookie = {
        same_site = "strict";
        secure = true;
      };
    };
  };
  persesConfigYaml = pkgs.writers.writeYAML "config.yaml" persesConfig;

  persesImage = pkgs.dockerTools.pullImage {
    imageName = "docker.io/persesdev/perses";
    imageDigest = "sha256:7d4647ce31841f67c2361bd10ea344de1edd7fbf65711c75805a5aacdc7735d0";
    sha256 = "sha256-oOQYJzGEEEkjfqlVkEGLOH3e4iywd8QnptY9UxPd1iw=";
  };
  persesHealthcheckImage = pkgs.dockerTools.streamLayeredImage {
    name = "perses";
    tag = "latest";
    fromImage = persesImage;
    contents = [ pkgs.curl ];
    config.Entrypoint = [ "/bin/perses" ];
    config.Cmd = [
      "--config=${persesConfigYaml}"
      "--log.level=info"
      "--web.listen-address=:${toString port}"
      # "--log.method-trace"
    ];
    config.Healthcheck = {
      Test = [
        "/bin/curl"
        "http://localhost:${toString port}/api/v1/health"
      ];
      Retries = 3;
    };
  };

  # persesEnv = config.virtualisation.oci-containers.containers.perses.environment;
  secrets = config.age.secrets;
in
{
  environment.systemPackages = [ terra.percli ];

  users.users.${user} = {
    isNormalUser = true;
    group = user;
    home = "/var/lib/${user}";
    createHome = true;
    linger = true;
    autoSubUidGidRange = true;
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
  age.secrets.persesAdminUser = {
    file = ../../../../secrets/persesAdminUser.age;
    owner = user;
    group = user;
  };

  systemd.services.perses.preStart =
    let
      provisioningFolder = "${config.users.users.${user}.home}/${provisionFolder}";
    in
    ''
      rm -rf ${provisioningFolder} && mkdir -p ${provisioningFolder}
      cp -f ${secrets.persesAdminUser.path} ${provisioningFolder}/1-admin-user.json
      cp -f ${./provision}/* ${provisioningFolder}
    '';

  virtualisation.oci-containers.containers.perses = {
    serviceName = "perses";
    image = "perses:latest";
    imageStream = persesHealthcheckImage;
    autoStart = true;
    # workdir = config.users.users.${user}.home;
    podman = {
      inherit user;
      sdnotify = "healthy";
    };
    environmentFiles = [ secrets.persesSecret.path ];
    volumes = [
      "/var/lib/perses:${persesConfig.database.file.folder}"
    ];
    extraOptions = [
      "--network=host"
    ];
  };

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

  # podmanning
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
