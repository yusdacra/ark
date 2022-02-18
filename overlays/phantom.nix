final: prev: {
  phantomstyle =
    prev.stdenv.mkDerivation
    {
      pname = "phantomstyle";
      version = "6e9580b";
      src =
        builtins.fetchGit
        {
          url = "https://github.com/randrew/phantomstyle.git";
          rev = "6e9580b72e372b5acecd616434eaf441bf73bcf4";
        };
      dontWrapQtApps = true;
      buildInputs = [prev.libsForQt5.qt5.qtbase];
      buildPhase =
        ''
          cd src/styleplugin
          qmake && make
        '';
      installPhase =
        ''
          mkdir -p $out/$qtPluginPrefix/styles
          mv libphantomstyleplugin.so $out/$qtPluginPrefix/styles
        '';
    };
}
