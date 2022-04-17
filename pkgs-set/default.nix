{
  channel,
  system,
  lib,
  ...
}: let
  pkgs = import channel {
    inherit system;
    config.allowUnfree = true;
    overlays =
      lib.mapAttrsToList
      (name: _: import "${./overlays}/${name}")
      (lib.readDir ./overlays);
  };
  pkgsToExport = import ./pkgs-to-export.nix;
in
  pkgs
  // {
    _exported = lib.getAttrs pkgsToExport pkgs;
  }
