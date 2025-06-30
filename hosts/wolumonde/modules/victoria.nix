{ lib, config, ... }:
let
  syslogUdp = 5113;
in
{
  services.victoriametrics = {
    enable = true;
    listenAddress = ":8428";
  };

  services.victorialogs = {
    enable = true;
    listenAddress = ":9428";
    # extraOptions = ["-syslog.listenAddr.udp=:${toString syslogUdp}" "-journald.maxRequestSize=1024000000"];
  };

  services.vmalert.instances."" = {
    enable = true;
    settings =
      let
        l = "http://localhost";
      in
      {
        "datasource.url" = "${l}${config.services.victorialogs.listenAddress}";
        "remoteWrite.url" = "${l}${config.services.victoriametrics.listenAddress}";
        "remoteRead.url" = "${l}${config.services.victoriametrics.listenAddress}";
        "rule.defaultRuleType" = "vlogs";
      };
  };

  services.fluent-bit.settings.pipeline.outputs = [
    # write metrics to victoriametrics via prometheus
    {
      name = "prometheus_remote_write";
      match = "metrics.*";
      port = lib.removePrefix ":" config.services.victoriametrics.listenAddress;
      uri = "/api/v1/write";
    }
    {
      name = "http";
      match = "logs.*";
      port = lib.removePrefix ":" config.services.victorialogs.listenAddress;
      uri = "/insert/jsonline?_stream_fields=stream&_msg_field=log&_time_field=date";
      format = "json_lines";
      json_date_format = "iso8601";
    }
    # write logs via syslog
    # {
    #   name = "syslog";
    #   match = "*.log";
    #   port = syslogUdp;
    #   syslog_maxsize = 4096;
    #   syslog_severity_key = "severity";
    #   syslog_facility_key = "facility";
    #   syslog_hostname_key = "hostname";
    #   syslog_appname_key = "appname";
    #   syslog_procid_key = "procid";
    #   syslog_msgid_key = "msgid";
    #   syslog_sd_key = "sd";
    #   syslog_message_key = "message";
    # }
  ];

  # services.journald.upload = {
  #   enable = true;
  #   settings.Upload.URL = "http://localhost${config.services.victorialogs.listenAddress}/insert/journald";
  # };
}
