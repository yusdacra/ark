{ pkgs, config, ... }:
let
  domain = "dash.gaze.systems";
  port = 7412;
  user = "perses";

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
      "--config=/etc/perses/config.yaml"
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

  persesEnv = config.virtualisation.oci-containers.containers.perses.environment;
  secrets = config.age.secrets;
  provisionFolder = "provisioning";
in
{
  environment.systemPackages = [ pkgs.percli ];

  users.users.${user} = {
    isNormalUser = true;
    group = user;
    home = "/var/lib/${user}";
    createHome = true;
    linger = true;
    autoSubUidGidRange = true;
  };
  users.groups.${user} = { };

  age.secrets.persesSecret = {
    file = ../../../secrets/persesSecret.age;
    owner = user;
    group = user;
  };
  age.secrets.persesAdminUser = {
    file = ../../../secrets/persesAdminUser.age;
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
      cp -f ${./perses/provision}/* ${provisioningFolder}
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
    environment = {
      PERSES_SECURITY_AUTHENTICATION_PROVIDERS_ENABLE_NATIVE = "true";
      PERSES_SECURITY_AUTHENTICATION_DISABLE_SIGN_UP = "true";
      PERSES_SECURITY_ENABLE_AUTH = "true";
      PERSES_SECURITY_COOKIE_SAME_SITE = "strict";
      PERSES_SECURITY_COOKIE_SECURE = "true";
      PERSES_PROVISIONING_FOLDERS_0 = "/perses/${provisionFolder}";
      # PERSES_PROVISIONING_INTERVAL = "1m";
      # PERSES_AUTHORIZATION_GUEST_PERMISSIONS_ACTIONS = "read";
    };
    volumes = [
      "/var/lib/perses:/perses"
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
