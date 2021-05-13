final: prev: {
  hikari = prev.hikari.overrideAttrs (old: {
    src = prev.fetchzip {
      url = "https://hub.darcs.net/raichoo/hikari/dist/hikari.zip";
      sha256 = "sha256-uEtmeQKg5II+Wy10YQCtId/iKnsV1hnz7PV6lOVqXzM=";
    };
    buildInputs = old.buildInputs ++ [ prev.pandoc ];
  });
}
