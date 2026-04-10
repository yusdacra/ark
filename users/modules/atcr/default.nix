{
  lib,
  config,
  terra,
  ...
}:
let
  l = lib;
  cfg = config.programs.atcr;
in
{
  options.programs.atcr = {
    enable = l.mkEnableOption "AT Container Registry credential helper";
    configureDocker = l.mkOption {
      type = l.types.bool;
      default = true;
      description = "Configure docker to use atcr as credential helper for atcr.io";
    };
  };

  config = l.mkIf cfg.enable {
    home.packages = [ terra.docker-credential-atcr ];

    home.file.".docker/config.json" = l.mkIf cfg.configureDocker {
      text = builtins.toJSON {
        credHelpers = {
          "atcr.io" = "atcr";
        };
      };
    };
  };
}
