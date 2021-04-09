final: prev: {
  hydrus = prev.hydrus.overrideAttrs (old: rec {
    pname = "hydrus";
    version = "434";
    src = builtins.fetchGit {
      url = "https://github.com/hydrusnetwork/hydrus.git";
      rev = "71bedccaeabf411307edeac3b03a0903d2c23ec8";
    };
    postPatch = ''
      sed 's;os\.path\.join(\sHC\.BIN_DIR,.*;"${prev.miniupnpc_2}/bin/upnpc";' \
        -i ./hydrus/core/networking/HydrusNATPunch.py
      sed 's;os\.path\.join(\sHC\.BIN_DIR,.*;"${prev.swftools}/bin/swfrender";' \
        -i ./hydrus/core/HydrusFlashHandling.py
    '';
  });
}
