{config, ...}: {
  networking.wireguard.enable = true;
  networking.wireguard.interfaces."wg0" = {
    listenPort = 51820;
    privateKeyFile = config.age.secrets.wgWolumondeKey.path;
    peers = [{
      publicKey = import ./wgTkarontoKey.pub;
      allowedIPs = ["10.99.0.2/32"];
    }];
  };
}