{lib, config, pkgs, ...}: let
  l = lib;
  t = l.types;
  cfg = config.services.netbird;
  wrapped = pkgs.writers.writeBashBin "netbird" ''
    ${pkgs.netbird}/bin/netbird \
      --daemon-addr "unix://$XDG_RUNTIME_DIR/netbird.sock" \
      --config "${config.xdg.configHome}/netbird/config.json" $@
  '';
  proxychainsCfg = pkgs.writers.writeText "proxychains.conf" ''
    proxy_dns
    quiet_mode
    [ProxyList]
    socks5 127.0.0.1 1080
  '';
  wrappedProxychains = pkgs.writers.writeBashBin "netbird-proxychains" ''
    ${pkgs.proxychains-ng}/bin/proxychains4 -f "${proxychainsCfg}" $@
  '';
in {
  options = {
    services.netbird = {
      enable = l.mkEnableOption "netbird client";
      managementUrl = l.mkOption {
        type = t.str;
        default = "https://api.netbird.cloud";
        description = "NetBird management URL";
      };
      setupKeyFile = l.mkOption {
        type = t.str;
        description = "Path to the setup key file";
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
    services.netbird.proxyScript = wrappedProxychains;
    systemd.user.services.netbird = {
      Unit = {
        Description = "NetBird Client";
        After = [ "network.target" ];
      };

      Service = {
        ExecStart = "${pkgs.netbird}/bin/netbird service run";
        Restart = "on-failure";
        RestartSec = "5s";
        Environment = l.mapAttrsToList (k: v: "${k}=${toString v}") {
          NB_WG_KERNEL_DISABLED = "true";
          NB_USE_NETSTACK_MODE = "true";
          NB_FORCE_USERSPACE_ROUTER = "true";
          NB_ENABLE_NETSTACK_LOCAL_FORWARDING = "true";
          NB_NETSTACK_SKIP_PROXY = "false";
          NB_SOCKS5_LISTENER_PORT = 1080;
          NB_SETUP_KEY_FILE = l.replaceString "\${XDG_RUNTIME_DIR}" "%t" cfg.setupKeyFile;
          NB_MANAGEMENT_URL = cfg.managementUrl;
          NB_CONFIG = "${config.xdg.configHome}/netbird/config.json";
          NB_LOG_FILE = "${config.xdg.dataHome}/netbird/netbird.log";
          NB_DAEMON_ADDR = "unix://%t/netbird.sock";
        };
      };

      Install.WantedBy = [ "network.target" ];
    };
  };
}
