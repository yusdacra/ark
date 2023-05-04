{config, ...}: {
  networking.wireguard.enable = true;
  networking.wireguard.interfaces."wg0" = {
    listenPort = 51820;
    privateKeyFile = config.age.secrets.wgProxyPrivateKey.path;
    peers = [{
      publicKey = import ./wgServerPublicKey.key.pub;
      allowedIPs = ["10.99.0.2/32"];
    }];
  };
}