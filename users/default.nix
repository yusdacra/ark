{
  inputs,
  lib,
  tlib,
  allPkgsSets,
  ...
}:
let
  mkHome =
    name: set:
    import "${inputs.home}/modules" {
      inherit (set) pkgs;
      configuration = import (./. + "/${name}/default.nix");
      extraSpecialArgs = {
        inherit (set) pkgs terra;
        inherit tlib inputs;
      };
    };

  users = {
    "dusk@devel.mobi" = allPkgsSets.x86_64-linux;
  };
in
lib.mapAttrs mkHome users
