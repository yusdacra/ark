{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [pkgs.wireguard-tools];

  systemd.network.enable = true;
  systemd.network.netdevs."wg0" = {
    enable = true;
    netdevConfig = {
      Name = "wg0";
      Kind = "wireguard";
    };
    wireguardConfig = {
      ListenPort = 51820;
      PrivateKeyFile = config.age.secrets.wgWolumondeKey.path;
    };
    wireguardPeers = [
      {
        wireguardPeerConfig = {
          PublicKey = builtins.readFile ./wgTkarontoKey.pub;
          AllowedIPs = ["10.99.0.2/32"];
        };
      }
    ];
  };
  systemd.network.networks."wg0" = {
    matchConfig.Name = "wg0";
    networkConfig.Address = "10.99.0.1/24";
    # routes = [
    #   {
    #     routeConfig = {
    #       Gateway = "10.99.0.1";
    #       Destination = "10.99.0.0/24";
    #     };
    #   }
    # ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking.firewall.allowedUDPPorts = [51820];
}
