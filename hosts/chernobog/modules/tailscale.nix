{ config, ... }:
{
  imports = [ ../../../modules/network/tailscale.nix ];
  networking.firewall.checkReversePath = "loose";
}
