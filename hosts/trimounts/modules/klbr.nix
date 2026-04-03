{ pkgs, ... }:
let
  index = pkgs.writeText "index.txt" ''
    hi there~

    you are currently interfacing with one of the data
    endpoints of entity with serial id /90008/. you can
    open a connection to https://ptr.pet/about for more.

    /discord           90.008/
    /bsky            @ptr.pet/
    /email     90008@klbr.net/

    /dig +short TXT klbr.net/
  '';
  root = pkgs.runCommand "root" { } ''
    mkdir -p $out
    ln -s ${index} $out/index.txt
  '';
in
{
  services.nginx.virtualHosts."klbr.net" = {
    inherit root;
    locations."/".index = "index.txt";
  };
}
