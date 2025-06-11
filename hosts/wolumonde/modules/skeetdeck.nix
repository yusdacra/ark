{ inputs, ... }:
{
  services.nginx.virtualHosts."skeetdeck.gaze.systems" = {
    forceSSL = true;
    enableACME = true;
    quic = true;
    kTLS = true;
    locations."/".root = inputs.skeetdeck;
  };
}
