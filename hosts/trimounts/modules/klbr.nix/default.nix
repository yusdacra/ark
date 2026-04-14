{ pkgs, ... }:
let
  style = ''
    <style>
    body{background: #1a1a1a; color: #d4d4d4; font-family: monospace; margin: 1em;}
    pre{margin:0;}
    img{display:block; margin: 1em 0;}
    </style>
  '';
  index = pkgs.writeText "index.html" ''
    ${style}
    <img title="by rotgutd on twt" src="/klbr-pets-by-rotgutd-on-twt.gif">
    <pre>
    hi there~

    you have reached klbr.net. this host operates
    several data endpoints and services. see below.
    we hope they will be of help to you ^^;

    //make use of/
    /did:plc mirror:   plc.klbr.net/
    /atproto spool:  spool.klbr.net/

    //reach out/
    /bsky           @klbr.net/
    /email     90008@klbr.net/

    dig +short TXT klbr.net
    </pre>
  '';
  spool = pkgs.writeText "index.html" ''
    ${style}
    <pre>
    you are currently downloading the documentation
    for atspool, a receipt printer interface for the
    atproto network. it speaks the net.klbr.spool
    lexicon and prints data on paper.

    //submit a job/
    create this record:
    {
      "$type": "net.klbr.spool.job",
      "content": {
        "$type": "net.klbr.spool.job.content.text",
        "text": "your message here"
      }
    }
    the record key should be a TID.

    //info/
    /there is an allowlist, mention/dm klbr.net on bsky/
    /source: tangled.org/ptr.pet/atspool/
    </pre>
    <img title="hi!!" src="/printer.webp">
    <pre>
    this is a physical device. be nice to it.
    </pre>
  '';
  mkRoot = index: files: pkgs.runCommand "root" { } ''
    mkdir -p $out
    ln -s ${index} $out/index.html
    ${pkgs.imagemagick}/bin/convert ${./ico.png} $out/favicon.ico
    ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (name: src: ''
      ln -s ${src} $out/${name}
    '') files)}
  '';
in
{
  services.nginx.virtualHosts."klbr.net" = {
    root = mkRoot index {
      "klbr-pets-by-rotgutd-on-twt.gif" = ./klbr-pets.gif;
    };
    locations."/".index = "index.html";
  };

  # spool
  security.acme.certs."klbr.net".extraDomainNames = ["spool.klbr.net"];
  services.nginx.virtualHosts."spool.klbr.net" = {
    useACMEHost = "klbr.net";
    quic = true;
    kTLS = true;
    forceSSL = true;
    root = mkRoot spool {
      "printer.webp" = ./printer.webp;
    };
    locations."/".index = "index.html";
  };
}