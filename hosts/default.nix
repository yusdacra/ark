{
  inputs,
  lib,
}: let
  baseModules = [
    ../modules
    ../secrets
    ../locale
    inputs.home.nixosModule
  ];

  mkSystem = name: system: let
    pkgs = lib.makePkgs system;
  in
    lib.nixosSystem {
      inherit system;
      modules = baseModules ++ [(import (./. + "/${name}/default.nix"))];
      specialArgs = {inherit inputs lib pkgs;};
    };
in {
  lungmen = mkSystem "lungmen" "x86_64-linux";
}
