{pkgs, ...}: let
  pkg = pkgs.helix;
  bin = "${pkg}/bin/hx";
in {
  environment.systemPackages = [pkg];
  environment.sessionVariables = {
    EDITOR = bin;
    VISUAL = bin;
  };
  environment.shellAliases = {e = bin;};
}
