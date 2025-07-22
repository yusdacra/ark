{
  inputs,
  lib,
  tlib,
  allPkgs,
  ...
}:
let
  mkHome =
    name: pkgs:
    import "${inputs.home}/modules" {
      inherit pkgs;
      configuration = import (./. + "/${name}/default.nix");
      extraSpecialArgs = {inherit tlib inputs pkgs;};
    };

  users = {
    "dusk@devel.mobi" = allPkgs.x86_64-linux;
  };
in
lib.mapAttrs mkHome users
