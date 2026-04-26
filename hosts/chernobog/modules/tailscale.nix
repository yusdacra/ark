{ lib, ... }:
{
  imports = [ ../../../modules/network/tailscale.nix ];
  networking.firewall.checkReversePath = "loose";
  services.tailscale.extraUpFlags = lib.mkForce ["--ssh"];
}
