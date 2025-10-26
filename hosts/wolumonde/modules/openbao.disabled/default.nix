{lib, config, ...}: let
  port = 5394;
  domain = "bao.${config.services.headscale.settings.dns.base_domain}";
  cfg = config.services.openbao.settings;
  apiAddress = "127.0.0.1:${toString port}";
in {
  imports = [./spindle-proxy];

  services.openbao = {
    enable = true;
    settings = {
      ui = true;

      listener.default = {
        type = "tcp";
        address = apiAddress;
        tls_disable = true;
      };

      cluster_addr = "http://127.0.0.1:8201";
      api_addr = "http://${apiAddress}";

      storage.file.path = "/var/lib/openbao/data";
    };
  };

  systemd.services.openbao.preStart = ''
    mkdir -p /var/lib/openbao
    rm -rf /var/lib/openbao/policies
    cp -r ${./policies} /var/lib/openbao/policies
  '';

  services.headscale.settings.dns.extra_records = [
    {
      name = domain;
      type = "A";
      value = "100.64.0.2";
    }
  ];
  services.nginx.virtualHosts.${domain} = {
    quic = true;
    locations."/".proxyPass = cfg.api_addr;
  };
}
