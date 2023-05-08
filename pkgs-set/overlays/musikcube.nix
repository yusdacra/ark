{inputs}: final: prev: {
  musikcube = inputs.nixpkgs-master.legacyPackages.${final.system}.musikcube;
}
