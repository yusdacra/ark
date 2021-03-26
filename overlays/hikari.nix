final: prev: {
  hikari = prev.hikari.overrideAttrs (old: rec {
    src = prev.fetchzip {
      url = "https://hub.darcs.net/raichoo/hikari/dist/hikari.zip";
      sha256 = "sha256-c7i/lekoS8FcsAHwXUw5IojC1xWS+sNeLVOzMf+dA5Q=";
    };
    buildInputs = old.buildInputs ++ [ prev.pandoc ];
  });
}
