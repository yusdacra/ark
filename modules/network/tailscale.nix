{ lib, ... }:
{
  services.tailscale = {
    enable = true;
    port = 41641;
    extraSetFlags = [ "--advertise-exit-node" ];
    # extraUpFlags = [ "--ssh" ];
    extraDaemonFlags = [ "--no-logs-no-support" ];
    useRoutingFeatures = "both";
    openFirewall = true;
  };

  networking.interfaces.tailscale0.useDHCP = lib.mkForce false;
}
