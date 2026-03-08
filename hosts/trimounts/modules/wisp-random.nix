{ pkgs, terra, ... }:
let
  random-wisp-place = pkgs.fetchgit {
    url = "https://tangled.org/did:plc:dfl62fgb7wtjj3fcbb72naae/random.wisp.place";
    rev = "refs/heads/main";
    hash = "sha256-h6yUVqVVtJOmxvf6xutP3EotIdzDGfRHnMgAEK2bnng=";
  };
  port = 14553;

  rootDomain = "ptr.pet";
  domain = "wisp-random.${rootDomain}";
in {
  users.users.random-wisp-place = {
    isSystemUser = true;
    group = "random-wisp-place";
  };
  users.groups.random-wisp-place = {};

  systemd.services.random-wisp-place = {
    description = "random-wisp-place";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];

    environment = {
      PORT = toString port;
      WISP_API_URL = "https://wisp.place";
      HYDRANT_BIN = "${terra.hydrant}/bin/hydrant";
    };

    serviceConfig = rec {
      ExecStart = "${pkgs.deno}/bin/deno run -A --unstable-kv ${random-wisp-place}/main.ts";
      User = "random-wisp-place";
      Group = "random-wisp-place";
      StateDirectory = "random-wisp-place";
      WorkingDirectory = "%S/${StateDirectory}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  security.acme.certs.${rootDomain}.extraDomainNames = [domain];
  services.nginx.virtualHosts.${domain} = {
    useACMEHost = rootDomain;
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/".proxyPass = "http://localhost:${toString port}";
  };
}
