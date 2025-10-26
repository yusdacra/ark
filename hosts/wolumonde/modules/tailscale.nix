{ config, ... }:
{
  imports = [ ../../../modules/network/tailscale.nix ];

  # age.secrets.tailscaleAuthKey.file = ../../../secrets/tailscaleAuthKey.age;
  # services.tailscale.authKeyFile = config.age.secrets.tailscaleAuthKey.path;

  networking.firewall.public.tailscale.allowedUDPPorts = [
    config.services.tailscale.port
  ];
}
