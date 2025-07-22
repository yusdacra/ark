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
    "${inputs.home}/nixos"
  ];

  mkSystem =
    name: set:
    import "${inputs.nixpkgs}/nixos/lib/eval-config.nix" {
      inherit lib;
      system = null;
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
