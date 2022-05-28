{
  inputs,
  system,
  lib,
  ...
}: let
  l = lib;
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
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
  };
  pkgsToExport = import ./pkgs-to-export.nix;
in
  pkgs
  // {
    _exported = l.getAttrs pkgsToExport pkgs;
  }
