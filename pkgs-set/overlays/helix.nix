{inputs}: final: prev: {
  helix = inputs.helix.packages.${prev.system}.default;
}
