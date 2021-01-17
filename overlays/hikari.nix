final: prev: {
  hikari = prev.hikari.overrideAttrs (old: rec {
    src = prev.fetchzip {
      url = "https://hub.darcs.net/raichoo/hikari/dist/hikari.zip";
      sha256 = "sha256-oVqn8rd9ajF0eS1D+L2Fw9n1MGuRzQbyWPYFueWF+hk=";
    };
    buildInputs = old.buildInputs ++ [ prev.pandoc ];
  });
}
