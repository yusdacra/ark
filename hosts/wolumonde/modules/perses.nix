{config, ...}:
let
  domain = "dash.gaze.systems";
  port = 7412;
in
{
  virtualisation.oci-containers.containers.pds = {
    image = "persesdev/perses";
    autoStart = true;
    environment = {
      PERSES_DATABASE_FILE_FOLDER = "/perses/db";
    };
    ports = [ "${port}:8080" ];
    volumes = [
      "/var/lib/perses:/perses"
    ];
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
      proxyPass = "http://localhost:${port}";
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
