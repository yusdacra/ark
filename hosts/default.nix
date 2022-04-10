{
  inputs,
  lib,
  tlib,
  ...
}: let
  baseModules = [
    ../modules
    ../secrets
    ../locale
    inputs.home.nixosModule
  ];

  mkSystem = name: system: let
    pkgs = tlib.makePkgs system;
  in
    lib.nixosSystem {
      inherit system;
      modules =
        baseModules
        ++ [
          {nixpkgs.pkgs = pkgs;}
          (import (./. + "/${name}/default.nix"))
        ];
      specialArgs = {inherit inputs tlib;};
    };

  systems = {
    lungmen = "x86_64-linux";
  };
in
  lib.mapAttrs mkSystem systems
