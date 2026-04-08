{
  services.nginx.virtualHosts."plc.gaze.systems" = {
    useACMEHost = "plc.gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://localhost:8000";
      proxyWebsockets = true;
    };
  };

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
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/root/allegedly2";
      ExecStart = "/root/allegedly2/target/release/allegedly mirror --wrap-fjall /root/plc3";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
