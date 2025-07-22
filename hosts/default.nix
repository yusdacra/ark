{
  inputs,
  lib,
  tlib,
  allPkgsSets,
  ...
}:
let
  baseModules = [
    ../modules
    ../locale
    inputs.home.nixosModules.default
  ];

  mkSystem =
    name: set:
    lib.nixosSystem {
      system = set.pkgs.system;
      modules = baseModules ++ [
        { networking.hostName = name; }
        { nixpkgs.pkgs = set.pkgs; }
        (import (./. + "/${name}/default.nix"))
      ];
      specialArgs = {
        inherit (set) terra;
        inherit inputs tlib;
      };
    };

  systems = {
    # lungmen = "x86_64-linux";
    # tkaronto = "x86_64-linux";
    wolumonde = allPkgsSets.x86_64-linux;
    wsl = allPkgsSets.x86_64-linux;
  };
in
lib.mapAttrs mkSystem systems
