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
        # set.inputs.nixpkgs.nixosModules.readOnlyPkgs
        { networking.hostName = name; }
        {
          nixpkgs.pkgs = set.pkgs;
          chaotic.nyx.overlay.enable = false;
        }
        set.inputs.chaotic.nixosModules.default
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
    # wolumonde = allPkgsSets.x86_64-linux;
    # wsl = allPkgsSets.x86_64-linux;
    dzwonek = allPkgsSets.x86_64-linux;
    volsinii = allPkgsSets.x86_64-linux;
    chernobog = allPkgsSets.x86_64-linux;
    trimounts = allPkgsSets.x86_64-linux;
    pupos = allPkgsSets.x86_64-linux;
  };
in
lib.mapAttrs mkSystem systems
