{inputs}: final: prev: {
  polymc = prev.polymc.overrideAttrs (old: {
    patches = [((toString inputs.self) + "/pkgs-set/patches/polymc-offline.patch")];
  });
}
