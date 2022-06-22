{inputs}: final: prev: {
  helix = inputs.helix.defaultPackage.${prev.system};
}
