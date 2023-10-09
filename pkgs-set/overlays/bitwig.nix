final: prev: {
  bitwig-studio = prev.bitwig-studio.overrideAttrs (old: rec {
    version = "5.0.4";
    src = final.fetchurl {
      url = "https://downloads.bitwig.com/stable/${version}/${old.pname}-${version}.deb";
      sha256 = "sha256-IkhUkKO+Ay1WceZNekII6aHLOmgcgGfx0hGo5ldFE5Y=";
    };
    postInstall = ''
      cp ${../patches/bitwig.jar} $out/libexec/bin/bitwig.jar
    '';
  });
}
