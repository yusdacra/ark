{pkgs, ...}:
let
  port = "1338";
  proxychainsCfg = pkgs.writers.writeText "proxychains.conf" ''
    proxy_dns
    quiet_mode
    [ProxyList]
    socks5 127.0.0.1 ${port}
  '';
  wrappedProxychains = pkgs.writers.writeBashBin "discord-proxy" ''
    ${pkgs.proxychains-ng}/bin/proxychains4 -f "${proxychainsCfg}" $@
  '';
in
{
  systemd.user.services.discord-socks-proxy = {
    Unit = {
      Description = "SSH SOCKS5 proxy for Discord";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.openssh}/bin/ssh -N -D 127.0.0.1:${port} root@trimounts";
      Restart = "on-failure";
      RestartSec = "3s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
  home.packages = [wrappedProxychains];
}
