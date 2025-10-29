{ config, ... }:
{
  imports = [ ../../../modules/network/tailscale.nix ];

  # age.secrets.tailscaleAuthKey.file = ../../../secrets/tailscaleAuthKey.age;
  # services.tailscale.authKeyFile = config.age.secrets.tailscaleAuthKey.path;

  services.tailscale = {
    extraSetFlags = [ "--advertise-exit-node" ];
    useRoutingFeatures = "both";
  };
}
