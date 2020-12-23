final: prev: {
  hikari = prev.hikari.overrideAttrs (old: rec {
    src = prev.fetchzip {
      url = "https://hub.darcs.net/raichoo/hikari/dist/hikari.zip";
      sha256 = "sha256-wguyND2LDyWtIoFibuxfFf9fi2D/0v7/fnGXy3JGjgM=";
    };
    buildInputs = old.buildInputs ++ [ prev.pandoc ];
  });
}
