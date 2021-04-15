final: prev: {
  hydrus = prev.hydrus.overrideAttrs (old: rec {
    version = "435";

    src = prev.fetchFromGitHub {
      owner = "hydrusnetwork";
      repo = old.pname;
      rev = "v${version}";
      sha256 = "sha256-+YOFqRgyNtdVBBCb6MWb+PqUoGvt8M0/ygiHrvxdWWg=";
    };

    postPatch = ''
      sed 's;os\.path\.join(\sHC\.BIN_DIR,.*;"${prev.miniupnpc_2}/bin/upnpc";' \
        -i ./hydrus/core/networking/HydrusNATPunch.py
      sed 's;os\.path\.join(\sHC\.BIN_DIR,.*;"${prev.swftools}/bin/swfrender";' \
        -i ./hydrus/core/HydrusFlashHandling.py
    '';
  });
}
