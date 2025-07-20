{ inputs, ... }:
{
  services.nginx.virtualHosts."skeetdeck.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
    locations."/".root = inputs.skeetdeck;
  };
}
