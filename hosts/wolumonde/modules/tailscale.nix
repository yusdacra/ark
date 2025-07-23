{config, ...}: {
  age.secrets.tailscaleAuthKey.file = ../../../secrets/tailscaleAuthKey.age;

  services.tailscale = {
    enable = true;
    port = 41641;
    extraSetFlags = [ "--advertise-exit-node" ];
    extraDaemonFlags = [ "--no-logs-no-support" ];
    useRoutingFeatures = "both";
    authKeyFile = config.age.secrets.tailscaleAuthKey.path;
    openFirewall = true;
  };

  networking.firewall.public.tailscale.allowedUDPPorts = [
    config.services.tailscale.port
  ];
}
