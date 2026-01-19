{ lib, ... }:
{
  imports = [ ../../../modules/network/tailscale.nix ];

  services.tailscale = {
    extraSetFlags = [ "--advertise-exit-node" ];
    useRoutingFeatures = lib.mkForce "both";
  };
}
