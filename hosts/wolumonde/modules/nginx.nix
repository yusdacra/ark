{ inputs, pkgs, ... }:
{
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    statusPage = true;
  };

  users.users.nginx.extraGroups = [ "acme" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = (import "${inputs.self}/personal.nix").emails.primary;
    certs."gaze.systems" = {
      webroot = "/var/lib/acme/acme-challenge";
      extraDomainNames = [
        "git.gaze.systems"
        "test.gaze.systems"
        # "ms.gaze.systems"
        # "mq.gaze.systems"
        # "couchdb.gaze.systems"
        "doc.gaze.systems"
        "pmart.gaze.systems"
        "limbus.gaze.systems"
        # "bsky.gaze.systems"
        "dawn.gaze.systems"
        "guestbook.gaze.systems"
        "webhook.gaze.systems"
        "dash.gaze.systems"
      ];
    };
  };

  services.prometheus.exporters.nginx = {
    enable = true;
    port = 9113;
  };

  services.vmalert.rules.groups = [
    {
      name = "nginx-logs";
      type = "vlogs";
      interval = "1m";
      rules = [
        {
          record = "nginx_request_count";
          expr = "* | stats count() as requests";
        }
        {
          record = "nginx_5xx_count";
          expr = ''* | status:~"5.." | stats count() as errors'';
        }
        {
          record = "nginx_request_latency_avg";
          expr = "* | stats avg(request_time) as avg_latency";
        }
      ];
    }
  ];
}
