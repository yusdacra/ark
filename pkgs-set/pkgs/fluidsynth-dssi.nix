{ lib, stdenv, fetchurl, alsa-lib, autoconf, automake, dssi, gtk2, libjack2,
ladspaH, ladspaPlugins, liblo, pkg-config, fluidsynth, rpm2targz, libtool, ... }:
stdenv.mkDerivation rec {
  pname = "fluidsynth-dssi";
  version = "1.9.9";

  src = fetchurl {
    url = "https://download.opensuse.org/source/distribution/leap/15.4/repo/oss/src/fluidsynth-dssi-1.9.9+git13012019-bp154.1.42.src.rpm";
    sha256 = "sha256-DJSrdxQpjvQTzio6e3p/iSYJWu+AbydyKkeKsRQA6qc=";
  };

  nativeBuildInputs = [ autoconf automake pkg-config rpm2targz libtool ];
  buildInputs = [ alsa-lib dssi gtk2 libjack2 ladspaH ladspaPlugins liblo fluidsynth.dev ];

  unpackPhase = ''
    rpm2targz $src
    tar -xf *.tar.gz
    rm *.src.tar.gz
    tar -xf *.tar.gz
    rm *.diff
    rm *.spec
    rm *.tar.gz
    cd fluidsynth-dssi-*
  '';
  configurePhase = ''
    $SHELL autogen.sh
    $SHELL configure
  '';
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    cp src/FluidSynth-DSSI_gtk $out/bin
    cp src/.libs/* $out/lib
  '';

  meta = with lib; {
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
