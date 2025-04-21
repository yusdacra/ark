{pkgs, config, ...}:
let
  index = pkgs.writeText "index.txt" ''
    meow :3c
  '';
  root = pkgs.runCommand "root" {} ''
    mkdir -p $out
    ln -s ${index} $out/index.txt
  '';
in
{
  services.nginx.virtualHosts."9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa" = {
    inherit root;
    quic = true;
    kTLS = true;
  };
}
