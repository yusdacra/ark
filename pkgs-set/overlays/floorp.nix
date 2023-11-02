{inputs}:
final: prev: {
  floorp = inputs.nixpkgs-floorp.legacyPackages.${final.system}.floorp;
}
