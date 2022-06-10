{
  python3,
  python3Packages,
  pulseaudio,
  stdenv,
  ...
}:
stdenv.mkDerivation {
  pname = "gaudible";
  version = "master";

  src = builtins.fetchGit {
    url = "https://github.com/dbazile/gaudible.git";
    rev = "ccd4ac14589f061c60217fe22120db8786898e4b";
    ref = "refs/heads/master";
    shallow = true;
  };

  buildInputs = [
    python3Packages.pygobject3
    python3Packages.dbus-python
  ];

  installPhase = ''
    mkdir -p $out/bin
    chmod +x gaudible.py
    cp gaudible.py $out/bin/gaudible
  '';
  fixupPhase = ''
    substituteInPlace $out/bin/gaudible \
      --replace "/usr/bin/paplay" "${pulseaudio}/bin/paplay" \
      --replace "/bin/env python3" "${python3}/bin/python"
  '';
}
