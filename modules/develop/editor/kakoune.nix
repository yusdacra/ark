{pkgs, ...}: let
  pkg = pkgs.kakoune-unwrapped;
in {
  environment.systemPackages = [pkg];
  environment.sessionVariables = {
    EDITOR = "${pkg}/bin/kak";
    VISUAL = "${pkg}/bin/kak";
  };
  environment.shellAliases = {k = "${pkg}/bin/kak";};
}
