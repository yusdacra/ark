{pkgs, ...}: {
  systemd.user.services.discord-socks-proxy = {
    Unit = {
      Description = "SSH SOCKS5 proxy for Discord";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.openssh}/bin/ssh -N -D 127.0.0.1:1338 root@trimounts";
      Restart = "on-failure";
      RestartSec = "3s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
