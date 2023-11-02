{
  stdenv,
  libsForQt5,
  ...
}:
stdenv.mkDerivation {
  pname = "phantomstyle";
  version = "309c97";

  src = builtins.fetchGit {
    url = "https://github.com/randrew/phantomstyle.git";
    rev = "309c97a955f6cdfb1987d1dd04c34d667e4bfce1";
  };

  dontWrapQtApps = true;

  buildInputs = [libsForQt5.qt5.qtbase];

  buildPhase = ''
    cd src/styleplugin
    qmake && make
  '';

  installPhase = ''
    mkdir -p $out/$qtPluginPrefix/styles
    mv libphantomstyleplugin.so $out/$qtPluginPrefix/styles
  '';
}
