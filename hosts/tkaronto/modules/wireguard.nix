{config, ...}: {
  systemd.network.enable = true;
  systemd.network.netdevs."wg0" = {
    enable = true;
    netdevConfig = {
      Name = "wg0";
      Kind = "wireguard";
    };
    wireguardConfig = {
      PrivateKeyFile = config.age.secrets.wgTkarontoKey.path;
    };
    wireguardPeers = [
      {
        wireguardPeerConfig = {
          PublicKey = builtins.readFile ./wgWolumondeKey.pub;
          AllowedIPs = ["10.99.0.1/32"];
          Endpoint = "${builtins.readFile ./wgWolumondeIp}:51820";
          PersistentKeepalive = 25;
        };
      }
    ];
  };
  systemd.network.networks."wg0" = {
    matchConfig.Name = "wg0";
    networkConfig.Address = "10.99.0.2/24";
    # routes = [
    #   {
    #     routeConfig = {
    #       Gateway = "10.99.0.1";
    #       Destination = "10.99.0.0/24";
    #       GatewayOnLink = true;
    #     };
    #   }
    # ];
  };
}
