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
  };
  pkgs = import stable {
    inherit system;
    overlays = [(_: _: import ./from-unstable.nix unstablePkgs)] ++ overlays;
  };
in
  pkgs
