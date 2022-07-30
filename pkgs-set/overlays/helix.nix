{inputs}: final: prev: {
  helix = inputs.helix.packages.${prev.system}.default.override {
    includeGrammarIf = grammar:
      prev.lib.any
      (name: grammar.name == name)
      ["toml" "rust" "nix" "protobuf" "yaml" "json" "markdown"];
  };
}
