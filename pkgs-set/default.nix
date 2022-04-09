{
  stable,
  unstable,
  system,
  lib,
}: let
  overlays =
    lib.mapAttrsToList
    (name: _: import "${./overlays}/${name}")
    (lib.readDir ./overlays);
  unstablePkgs = import unstable {
    inherit system;
    config.allowUnfree = true;
  };
  pkgs = import stable {
    inherit system;
    config.allowUnfree = true;
    overlays = [(_: _: import ./from-unstable.nix unstablePkgs)] ++ overlays;
  };
in
  pkgs
