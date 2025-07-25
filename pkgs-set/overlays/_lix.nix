{ inputs }:
final: prev:
(import "${inputs.lix-module}/overlay.nix" { lix = null; }) final (
  prev
  // {
    lix = final.lixPackageSets.latest.lix;
  }
)
