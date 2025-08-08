{
  callPackage,
  inputs,
  tangled-modules,
  tangled-sqlite-lib,
  ...
}:
(callPackage "${inputs.tangled}/nix/pkgs/spindle.nix" {
  modules = tangled-modules;
  sqlite-lib = tangled-sqlite-lib;
}).overrideAttrs
  (_: {
    src = inputs.tangled;
  })
