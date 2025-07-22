{
  inputs,
  lib,
  tlib,
  allPkgs,
  ...
}:
let
  baseModules = [
    ../modules
    ../locale
    inputs.home.nixosModules.default
  ];

  mkSystem =
    name: pkgs:
    lib.nixosSystem {
      system = pkgs.system;
      modules = baseModules ++ [
        { networking.hostName = name; }
        { nixpkgs.pkgs = pkgs; }
        (import (./. + "/${name}/default.nix"))
      ];
      specialArgs = { inherit inputs tlib; };
    };

  systems = {
    # lungmen = "x86_64-linux";
    # tkaronto = "x86_64-linux";
    wolumonde = allPkgs.x86_64-linux;
    wsl = allPkgs.x86_64-linux;
  };
in
lib.mapAttrs mkSystem systems
