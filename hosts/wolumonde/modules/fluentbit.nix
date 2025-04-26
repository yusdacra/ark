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
      parsers = [
        {
          name = "nginx";
          format = "regex";
          regex = ''^(?<remote_addr>[^ ]+) - (?<remote_user>[^ ]+) \[(?<time_local>[^\]]+)\] "(?<request>[^"]*)" (?<status>\d{3}) (?<body_bytes_sent>\d+) "(?<http_referer>[^"]*)" "(?<http_user_agent>[^"]*)" (?<request_time>[0-9\.]+)$'';
          time_key = "time_local";
          time_format = "%d/%b/%Y:%H:%M:%S %z";
          time_keep = "off";
        }
      ];
      pipeline = {
        inputs = [
          {
            name = "tail";
            tag = "nginx.access";
            path = "/var/lib/nginx/access.log";
            db = "/var/lib/fluent-bit/nginx-access.db";
            parser = "nginx";
          }
        ];
        outputs = [
          {
            name = "http";
            match = "nginx.access";
            host = "127.0.0.1";
            port = lib.removePrefix ":" config.services.victorialogs.listenAddress;
            uri = "/insert/jsonline?_stream_fields=stream&_msg_field=log&_time_field=date";
            format = "json_lines";
            json_date_format = "iso8601";
          }
        ];
      };
    };
  };

  systemd.services.fluent-bit.serviceConfig.StateDirectory = "fluent-bit";
}
