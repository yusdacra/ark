{ lib, ... }:
{
  imports = [ ../../../modules/network/tailscale.nix ];

  services.tailscale.useRoutingFeatures = lib.mkForce "server";

  # age.secrets.tailscaleAuthKey.file = ../../../secrets/tailscaleAuthKey.age;
  # services.tailscale.authKeyFile = config.age.secrets.tailscaleAuthKey.path;
}
