final: prev: {
  grit = prev.grit.overrideAttrs (old: rec {
    version = "0.3.0";

    src = prev.fetchFromGitHub {
      owner = "climech";
      repo = old.pname;
      rev = "v${version}";
      sha256 = "sha256-c8wBwmXFjpst6UxL5zmTxMR4bhzpHYljQHiJFKiNDms=";
    };
  });
}
