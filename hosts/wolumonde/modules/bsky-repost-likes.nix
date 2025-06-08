{
  pkgs,
  inputs,
  ...
}:
let
  pkg = inputs.bsky-repost-likes.packages.${pkgs.system}.default;
in
{
  users.users.repostream = {
    isSystemUser = true;
    group = "repostream";
  };
  users.groups.repostream = { };

  systemd.services.repostream = {
    description = "repostream";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      User = "repostream";
      ExecStart = "${pkg}/bin/bsky-repost-likes";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "/var/lib/repostream";
    };
  };

  services.nginx.virtualHosts."likes.gaze.systems" = {
    useACMEHost = "gaze.systems";
    quic = true;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:8080";
      extraConfig = ''
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header id $request_id;
        proxy_read_timeout 7d;
      '';
    };
  };
}
