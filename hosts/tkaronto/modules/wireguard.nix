{config, ...}: {
  networking.wireguard.enable = true;
  networking.wireguard.interfaces."wg0" = {
    privateKeyFile = config.age.secrets.wgServerPrivateKey.path;
    peers = [{
      publicKey = import ./wgProxyPublicKey.key.pub;
      allowedIPs = ["10.99.0.1/32"];
      endpoint = "${import ./wgProxyPublicIp}:51820";
    }];
  };
}