final: prev: {
  calf = prev.calf.overrideAttrs (old: {
    src = final.fetchFromGitHub {
      owner = "calf-studio-gear";
      repo = "calf";
      rev = "024e9deab2d32b26e90b556d36d9c74f6b0aeb17";
      sha256 = "sha256-av6quHkesND9M8vlkOQKLXK4prf+oQxOLANuNsWL+eg=";
    };
    nativeBuildInputs = old.nativeBuildInputs ++ (with final; [automake autoconf pkg-config libtool]);
    configurePhase = ''
      $SHELL autogen.sh
    '';
  });
}
