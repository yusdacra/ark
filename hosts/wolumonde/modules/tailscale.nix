{
  services.tailscale.enable = true;
  services.tailscale.extraSetFlags = [ "--advertise-exit-node" ];
}
