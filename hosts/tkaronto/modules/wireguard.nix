{config, ...}: {
  networking.wireguard.enable = true;
  networking.wireguard.interfaces."wg0" = {
    privateKeyFile = config.age.secrets.wgTkarontoKey.path;
    peers = [{
      publicKey = builtins.readFile ./wgWolumondeKey.pub;
      allowedIPs = ["10.99.0.1/32"];
      endpoint = "${builtins.readFile ./wgWolumondeIp}:51820";
    }];
  };
}