{ pkgs, ... }:
let
  port = toString 9000;
in
{
  services.webhook.hooks."deploy-wolumonde" = {
    execute-command = "${pkgs.curl}/bin/curl";
    pass-arguments-to-command = builtins.map (n: {
      source = "string";
      name = n;
    }) [ "http://higashi:${port}/hooks/deploy-wolumonde" ];
  };

  services.headscale.acl.rules = [
    {
      proto = "tcp";
      src = [ "wolumonde" ];
      dst = [ "higashi:${port}" ];
    }
  ];
}
