{
  lib,
  tlib,
  allPkgsSets,
  ...
}:
let
  mkSystem =
    name: set:
    import "${set.inputs.nixpkgs}/nixos/lib/eval-config.nix" {
      inherit lib;
      system = null;
      modules = [
        { networking.hostName = name; }
        { nixpkgs.pkgs = set.pkgs; }
        (import (./. + "/${name}/default.nix"))
      ];
      specialArgs = {
        inherit (set) terra inputs;
        inherit tlib;
      };
    };

  systems = {
    # lungmen = "x86_64-linux";
    # tkaronto = "x86_64-linux";
    wolumonde = allPkgsSets.x86_64-linux;
    # wsl = allPkgsSets.x86_64-linux;
    dzwonek = allPkgsSets.x86_64-linux;
    volsinii = allPkgsSets.x86_64-linux;
  };
in
lib.mapAttrs mkSystem systems
