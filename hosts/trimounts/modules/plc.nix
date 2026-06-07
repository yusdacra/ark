{
  security.acme.certs."plc.klbr.net" = {};
  services.nginx.virtualHosts."plc.klbr.net" = {
    useACMEHost = "plc.klbr.net";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://localhost:8000";
      proxyWebsockets = true;
    };
  };

  systemd.services.allegedly = {
    description = "allegedly mirror service";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    environment = { RUST_LOG="allegedly=debug"; };
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/root/allegedly";
      ExecStart = "/root/allegedly/target/release/allegedly mirror --wrap-fjall /root/plc3";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
