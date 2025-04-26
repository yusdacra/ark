{ config, ... }:
{
  # Enable single-node VictoriaMetrics on port 8428 (default)
  services.victoriametrics = {
    enable = true;
    listenAddress = ":8428"; # default port for metrics
    prometheusConfig = {
      scrape_configs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "localhost:9100" ];
              labels.type = "node";
            }
          ];
        }
        {
          job_name = "nginx";
          static_configs = [ { targets = [ "localhost:9113" ]; } ];
        }
      ];
    };
  };

  # Enable VictoriaLogs (logs database) on port 9428 (default)
  services.victorialogs = {
    enable = true;
    listenAddress = ":9428"; # default port for logs
    # You can add extra options if needed, e.g. authentication or retention
    # extraOptions = [ "-loggerLevel=INFO" ];
  };

  # Enable vmalert for LogsQL recording rules
  services.vmalert = {
    enable = true;
    # Point vmalert to VictoriaLogs and VictoriaMetrics
    settings = {
      "datasource.url" = "http://127.0.0.1${config.services.victorialogs.listenAddress}"; # VictoriaLogs address
      "remoteWrite.url" = "http://127.0.0.1${config.services.victoriametrics.listenAddress}"; # Remote-write to VictoriaMetrics
      "remoteRead.url" = "http://127.0.0.1${config.services.victoriametrics.listenAddress}"; # Remote-read from VictoriaMetrics
      "rule.defaultRuleType" = "vlogs"; # Use LogsQL rules by default
    };
  };
}
