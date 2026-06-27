{
  lib,
  config,
  pkgs,
  ...
}:
let
  l = lib;
  t = l.types;

  instanceModule = { name, config, ... }:
    let
      proxychainsCfg = pkgs.writers.writeText "proxychains-${name}.conf" ''
        proxy_dns
        quiet_mode
        [ProxyList]
        socks5 127.0.0.1 ${toString config.port}
        http 127.0.0.1 ${toString config.port}
      '';
      proxyScript' = pkgs.writers.writeBashBin "tailscale-${name}-proxychains" ''
        ${pkgs.proxychains-ng}/bin/proxychains4 -f "${proxychainsCfg}" "$@"
      '';
      cli' = pkgs.writers.writeBashBin "tailscale-${name}" ''
        ${pkgs.tailscale}/bin/tailscale --socket "$XDG_RUNTIME_DIR/tailscaled-${name}.sock" "$@"
      '';
    in
    {
      options = {
        enable = l.mkEnableOption "tailscale client";
        controlServer = l.mkOption {
          type = t.str;
          default = "https://controlplane.tailscale.com";
          description = "tailscale control server URL";
        };
        authKeyFile = l.mkOption {
          type = t.nullOr t.str;
          default = null;
          description = "path to the auth key file";
        };
        extraUpFlags = l.mkOption {
          type = t.listOf t.str;
          default = [ ];
          description = "extra flags to pass to tailscale up";
        };
        port = l.mkOption {
          type = t.port;
          default = 1055;
          description = "port for the SOCKS5/HTTP proxy — must be unique per instance";
        };
        proxyScript = l.mkOption {
          type = t.package;
          readOnly = true;
          description = "proxychains-wrapped script for this instance";
        };
        cli = l.mkOption {
          type = t.package;
          readOnly = true;
          description = "wrapped tailscale-<name> binary for this instance";
        };
      };
      config = {
        proxyScript = proxyScript';
        cli = cli';
      };
    };

  cfg = config.services.tailscale;
  enabled = l.filterAttrs (_: icfg: icfg.enable) cfg;
in
{
  options.services.tailscale = l.mkOption {
    type = t.attrsOf (t.submodule instanceModule);
    default = { };
    description = "tailscale instances keyed by name";
  };

  config = l.mkIf (enabled != { }) {
    home.packages = l.concatLists (
      l.mapAttrsToList (_: icfg: [ icfg.cli icfg.proxyScript ]) enabled
    );

    systemd.user.services = l.mapAttrs' (
      name: icfg:
      l.nameValuePair "tailscaled-${name}" {
        Unit = {
          Description = "tailscaled (${name})";
        };
        Service =
          {
            StateDirectory = "tailscale-${name}";
            ExecStart = "${pkgs.tailscale}/bin/tailscaled --tun=userspace-networking --state=%S/tailscale-${name}/tailscaled.state --socks5-server=localhost:${toString icfg.port} --outbound-http-proxy-listen=localhost:${toString icfg.port} --socket %t/tailscaled-${name}.sock";
            Restart = "on-failure";
            RestartSec = "5s";
          }
          // l.optionalAttrs (icfg.authKeyFile != null) {
            ExecStartPost = "${icfg.cli}/bin/tailscale-${name} up --reset --login-server=${icfg.controlServer} --auth-key=file:${icfg.authKeyFile} ${l.concatStringsSep " " icfg.extraUpFlags}";
          };
        Install.WantedBy = [ "default.target" ];
      }
    ) enabled;
  };
}
