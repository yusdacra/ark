final: prev: {
  hydrus = prev.hydrus.overrideAttrs (old: rec {
    pname = "hydrus";
    version = "433";
    src = prev.fetchFromGitHub {
      owner = "hydrusnetwork";
      repo = "hydrus";
      rev = "v433";
      sha256 = "sha256-RZKmtVSCkMuJxuGGgk92J0Y71aHRZYsaBmUZy/gC9Ms=";
    };
  });
}
