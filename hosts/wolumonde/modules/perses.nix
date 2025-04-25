{config, ...}:
let
  domain = "dash.gaze.systems";
  port = 7412;
in
{
  users.users.perses.isSystemUser = true;
  users.users.perses.group = "perses";
  users.groups.perses = {};

  virtualisation.oci-containers.containers.perses = {
    serviceName = "perses";
    image = "docker.io/persesdev/perses:v0.51";
    autoStart = true;
    user = "perses:perses";
    workdir = "/var/lib/perses";
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
