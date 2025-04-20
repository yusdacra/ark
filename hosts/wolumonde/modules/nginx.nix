{inputs, ...}: {
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };

  users.users.nginx.extraGroups = ["acme"];

  security.acme = {
    acceptTerms = true;
    defaults.email = (import "${inputs.self}/personal.nix").emails.primary;
    # certs."9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa" = {
    #   webroot = "/var/lib/acme/acme-challenge";
    # };
    certs."gaze.systems" = {
      webroot = "/var/lib/acme/acme-challenge";
      extraDomainNames = [
        "git.gaze.systems"
        "test.gaze.systems"
        # "ms.gaze.systems"
        # "mq.gaze.systems"
        "couchdb.gaze.systems"
        "doc.gaze.systems"
        "pmart.gaze.systems"
        "limbus.gaze.systems"
        # "bsky.gaze.systems"
        "dawn.gaze.systems"
        # "guestbook.gaze.systems"
        "webhook.gaze.systems"
        "about.gaze.systems"
      ];
    };
  };
}
