final: prev: {
  navidrome = prev.navidrome.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./origin_url.patch];
    doCheck = false;
  });
}
