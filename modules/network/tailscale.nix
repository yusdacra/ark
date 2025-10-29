{ lib, ... }:
{
  services.tailscale = {
    enable = true;
    port = 41641;
    # extraUpFlags = [ "--ssh" ];
    extraDaemonFlags = [ "--no-logs-no-support" ];
    openFirewall = true;
  };

  networking.interfaces.tailscale0.useDHCP = lib.mkForce false;
}
