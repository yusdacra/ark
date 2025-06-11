{ pkgs, ... }:
let
  index = pkgs.writeText "index.txt" ''
    hi there~

    you are currently interfacing with one of the data endpoints
    of entity with serial id /90008/. you may want to open a
    connection to https://gaze.systems/about for more data.

    /discord         yusdacra/
    /bsky           @poor.dog/
    /email 90008@gaze.systems/

    /dig +short TXT 9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa/
  '';
  root = pkgs.runCommand "root" { } ''
    mkdir -p $out
    ln -s ${index} $out/index.txt
  '';
in
{
  services.nginx.virtualHosts."9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa" = {
    inherit root;
    locations."/".index = "index.txt";
    quic = true;
    kTLS = true;
  };
}
