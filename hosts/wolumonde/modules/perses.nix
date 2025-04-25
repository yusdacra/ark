{config, ...}:
let
  domain = "dash.gaze.systems";
  port = 7412;
  # user = "perses";
in
{
  # users.users.${user} = {
  #   isNormalUser = true;
  #   group = user;
  #   home = "/var/lib/${user}";
  #   createHome = true;
  #   linger = true;
  #   autoSubUidGidRange = true;
  # };
  # users.groups.${user} = {};

  virtualisation.oci-containers.containers.perses = {
    serviceName = "perses";
    image = "docker.io/persesdev/perses:v0.51";
    autoStart = true;
    # workdir = config.users.users.${user}.home;
    # podman = {
    #   inherit user;
    # };
    environment = {
      PERSES_SECURITY_AUTHENTICATION_PROVIDERS_ENABLE_NATIVE = "true";
      PERSES_SECURITY_ENABLE_AUTH = "true";
      PERSES_SECURITY_COOKIE_SAME_SITE = "strict";
      PERSES_SECURITY_COOKIE_SECURE = "true";
      # PERSES_AUTHORIZATION_GUEST_PERMISSIONS_ACTIONS = "read";
    };
    volumes = [
      "/var/lib/perses:/perses"
    ];
    ports = [ "${toString port}:8080" ];
    extraOptions = [
      # "--network=host"
      "--label=io.containers.autoupdate=registry"
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

  # podmanning
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # update containers automatically
  systemd.timers."podman-auto-update" = {
    enable = true;
    timerConfig = {
      OnCalendar = "*-*-* 4:00:00";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };
}
