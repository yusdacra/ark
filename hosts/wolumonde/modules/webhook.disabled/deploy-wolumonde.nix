{ pkgs, ... }:
{
  services.webhook.hooks."deploy-wolumonde" = {
    execute-command = "${pkgs.curl}/bin/curl";
    pass-arguments-to-command = builtins.map (n: {
      source = "string";
      name = n;
    }) [ "http://higashi:9000/hooks/deploy-wolumonde" ];
  };
}
