{
  pkgs,
  config,
  lib,
  ...
}:
{
  services.fluent-bit = {
    enable = true;
    settings = {
      service.flush = 1;
      pipeline.inputs = [
        {
          name = "node_exporter_metrics";
          tag = "metrics.node";
          scrape_interval = 5;
        }
        # {
        #   name = "dummy";
        #   tag = "logs.dummy";
        #   dummy = ''{"_msg": "dummy"}'';
        # }
        {
          name = "fluentbit_metrics";
          tag = "metrics.fluentbit";
          scrape_interval = 5;
        }
      ];
    };
  };

  systemd.services.fluent-bit.serviceConfig.StateDirectory = "fluent-bit";
}
