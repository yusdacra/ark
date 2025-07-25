{ callPackage, inputs, ... }:
callPackage "${inputs.tangled}/nix/pkgs/sqlite-lib.nix" {
  sqlite-lib-src = inputs.tangled-sqlite-lib;
}
