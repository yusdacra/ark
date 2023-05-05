{config, ...}: {
  networking.wireguard.enable = true;
  networking.wireguard.interfaces."wg0" = {
    privateKeyFile = config.age.secrets.wgTkarontoKey.path;
    peers = [{
      publicKey = import ./wgWolumondeKey.pub;
      allowedIPs = ["10.99.0.1/32"];
      endpoint = "${import ./wgWolumondeIp}:51820";
    }];
  };
}