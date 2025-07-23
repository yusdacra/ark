{lib, config, pkgs, ...}: let
  l = lib;
  t = l.types;
  cfg = config.services.tailscale;
  proxychainsCfg = pkgs.writers.writeText "proxychains.conf" ''
    proxy_dns
    quiet_mode
    [ProxyList]
    socks5 127.0.0.1 1055
    http 127.0.0.1 1055
  '';
  wrappedProxychains = pkgs.writers.writeBashBin "tailscale-proxychains" ''
    ${pkgs.proxychains-ng}/bin/proxychains4 -f "${proxychainsCfg}" $@
  '';
  wrapped = pkgs.writers.writeBashBin "tailscale" ''
    ${pkgs.tailscale}/bin/tailscale --socket $XDG_RUNTIME_DIR/tailscaled.sock $@
  '';
in {
  options = {
    services.tailscale = {
      enable = l.mkEnableOption "tailscale client";
      controlServer = l.mkOption {
        type = t.str;
        default = "https://controlplane.tailscale.com";
        description = "tailscale control server URL";
      };
      authKeyFile = l.mkOption {
        type = t.nullOr t.str;
        default = null;
        description = "Path to the auth key file";
      };
      extraUpFlags = l.mkOption {
        type = t.listOf t.str;
        default = [];
        description = "Extra flags to pass to tailscale up";
      };
      proxyScript = l.mkOption {
        type = t.package;
        description = "path to a script that uses proxychains to proxy traffic";
        readOnly = true;
      };
    };
  };
  config = l.mkIf cfg.enable {
    home.packages = [ wrapped wrappedProxychains ];
    services.tailscale.proxyScript = wrappedProxychains;
    systemd.user.services.tailscaled = {
      Unit = {
        Description = "tailscaled";
        After = [ "network.target" ];
      };

      Service = {
        ExecStart = "${pkgs.tailscale}/bin/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 --socket %t/tailscaled.sock";
        Restart = "on-failure";
        RestartSec = "5s";
      } // l.optionalAttrs (cfg.authKeyFile != null) {
        ExecStartPost = "${wrapped}/bin/tailscale up --reset --login-server=${cfg.controlServer} --auth-key=file:${cfg.authKeyFile} ${l.concatStringsSep " " cfg.extraUpFlags}";
      };

      Install.WantedBy = [ "network.target" ];
    };
  };
}
