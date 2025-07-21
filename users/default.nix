{
  inputs,
  lib,
  tlib,
  ...
}:
let
  mkHome =
    name: system:
    let
      pkgs = tlib.makePkgs system;
    in
    import "${inputs.home}/modules" {
      inherit pkgs;
      configuration = import (./. + "/${name}/default.nix");
      extraSpecialArgs = {inherit tlib inputs;};
    };

  users = {
    "dusk@devel.mobi" = "x86_64-linux";
  };
in
lib.mapAttrs mkHome users
