{
  inputs,
  system,
  lib,
  tlib,
  ...
}: let
  l = lib;
  overlays =
    l.mapAttrsToList
    (
      name: _: let
        o = import "${./overlays}/${name}";
      in
        if (l.functionArgs o) ? inputs
        then o {inherit inputs;}
        else o
    )
    (l.readDir ./overlays);
  newPkgs =
    l.mapAttrsToList
    (
      name: _: final: prev: {
        ${l.removeSuffix ".nix" name} =
          final.callPackage
          "${./pkgs}/${name}"
          {inherit inputs tlib;};
      }
    )
    (l.readDir ./pkgs);
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = overlays ++ newPkgs;
  };
  pkgsToExport = import ./pkgs-to-export.nix pkgs;
in
  pkgs
  // {
    _exported = pkgsToExport;
  }
