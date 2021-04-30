final: prev: {
  kcr = prev.stdenv.mkDerivation {
    pname = "kcr";
    version = "nightly";

    src = prev.fetchzip {
      url = "https://github.com/alexherbo2/kakoune.cr/releases/download/nightly/kakoune.cr-nightly-x86_64-unknown-linux-musl.zip";
      stripRoot = false;
      sha256 = "sha256-Ly6zsm2cea1GUpgwmmlkDO2UI0wsp/tSQSZpfvjLCrM=";
    };

    installPhase = ''
      mkdir -p $out/bin
      install bin/kcr $out/bin
    '';
  };
}
