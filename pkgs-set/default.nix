{
  inputs,
  system,
  lib,
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
          prev.callPackage
          "${./pkgs}/${name}"
          {inherit inputs;};
      }
    )
    (l.readDir ./pkgs);
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = overlays ++ newPkgs;
  };
  pkgsToExport = import ./pkgs-to-export.nix;
in
  pkgs
  // {
    _exported = l.getAttrs pkgsToExport pkgs;
  }
