{
  services.transmission = {
    enable = true;
    openPeerPorts = true;
    openRPCPort = false; # we use tailscale
    settings = {
      watch-dir-enabled = true;
    };
  };
}
