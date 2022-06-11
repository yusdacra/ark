{
  config,
  inputs,
  secrets,
  ...
}: let
  smosDir = "${config.home.homeDirectory}/smos";
in {
  imports = ["${inputs.smos}/nix/home-manager-module.nix"];
  programs.smos = {
    enable = true;
    notify.enable = true;
    config = {
      workflow-dir = smosDir + "/workflows";
      github.oauth-token = secrets.githubToken;
    };
  };
  home.shellAliases = {
    s = "smos";
    sin = "smos ${config.programs.smos.config.workflow-dir}/inbox.smos";
    sq = "smos-query";
    sqn = "smos-query next";
    sqp = "smos-query projects";
    sgh = "smos-github";
    sghi = "smos-github import";
    sghl = "smos-github list";
  };
}
