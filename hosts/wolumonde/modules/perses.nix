{pkgs, config, ...}:
let
  domain = "dash.gaze.systems";
  port = 7412;
  user = "perses";

  persesImage = pkgs.dockerTools.pullImage {
    imageName = "docker.io/persesdev/perses";
    imageDigest = "sha256:30a6c2d66e48d64619076e4f088d7d535d14409c9083256f0d56c4cc91294684";
    sha256 = "sha256-U6sorhUnQ0AH9cygnrnz6XDFEtD41GtQSie/Hri7u8c=";
  };
  persesHealthcheckImage = pkgs.dockerTools.streamLayeredImage {
    name = "perses";
    tag = "latest";
    fromImage = persesImage;
    contents = [pkgs.curl];
    config.Entrypoint = ["/bin/perses"];
    config.Cmd = ["--config=/etc/perses/config.yaml" "--log.level=error"];
    config.Healthcheck = {
      Test = ["/bin/curl" "http://localhost:8080/api/v1/health"];
      Retries = 3;
    };
  };
in
{
  users.users.${user} = {
    isNormalUser = true;
    group = user;
    home = "/var/lib/${user}";
    createHome = true;
    linger = true;
    autoSubUidGidRange = true;
  };
  users.groups.${user} = {};

  age.secrets.persesSecret = {
    file = ../../../secrets/persesSecret.age;
    inherit user;
    group = user;
  };

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
    environmentFiles = [config.age.secrets.persesSecret.path];
    environment = {
      PERSES_SECURITY_AUTHENTICATION_PROVIDERS_ENABLE_NATIVE = "true";
      PERSES_SECURITY_AUTHENTICATION_DISABLE_SIGN_UP = "true";
      PERSES_SECURITY_ENABLE_AUTH = "true";
      PERSES_SECURITY_COOKIE_SAME_SITE = "strict";
      PERSES_SECURITY_COOKIE_SECURE = "true";
      # PERSES_AUTHORIZATION_GUEST_PERMISSIONS_ACTIONS = "read";
    };
    volumes = [
      "/var/lib/perses:/perses"
    ];
    ports = [ "${toString port}:8080" ];
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

  # podmanning
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
