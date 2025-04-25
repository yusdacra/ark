{config, ...}:
let
  domain = "dash.gaze.systems";
  port = 7412;
in
{
  users.users.perses = {
    isNormalUser = true;
    group = "perses";
    home = "/var/lib/perses";
    createHome = true;
    linger = true;
    autoSubUidGidRange = true;
  };
  users.groups.perses = {};

  virtualisation.oci-containers.containers.perses = {
    serviceName = "perses";
    image = "docker.io/persesdev/perses:v0.51";
    autoStart = true;
    workdir = config.users.users.perses.home;
    podman.user = "perses";
    environment = {
      PERSES_AUTHENTICATION_ENABLE_NATIVE = "true";
      # PERSES_AUTHORIZATION_GUEST_PERMISSIONS_ACTIONS = "read";
    };
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
