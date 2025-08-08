{
  callPackage,
  inputs,
  tangled-modules,
  tangled-sqlite-lib,
  ...
}:
let
  unwrapped =
    (callPackage "${inputs.tangled}/nix/pkgs/knot-unwrapped.nix" {
      modules = tangled-modules;
      sqlite-lib = tangled-sqlite-lib;
    }).overrideAttrs
      (_: {
        src = inputs.tangled;
      });
in
callPackage "${inputs.tangled}/nix/pkgs/knot.nix" {
  knot-unwrapped = unwrapped;
}
