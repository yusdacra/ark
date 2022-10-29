{
  lib,
  stdenv,
  fetchFromGitLab,
  nix-update-script,
  meson,
  cmake,
  ninja,
  gettext,
  python3,
  rustPlatform,
  pkg-config,
  glib,
  libhandy,
  libsecret,
  libshumate,
  gtk4,
  gtksourceview5,
  libadwaita,
  llvmPackages,
  glibc,
  wayland,
  pipewire,
  dbus,
  openssl,
  sqlite,
  gst_all_1,
  cairo,
  gdk-pixbuf,
  gspell,
  wrapGAppsHook,
  desktop-file-utils,
  appstream-glib,
  ...
}:
stdenv.mkDerivation rec {
  pname = "fractal-next";
  version = "26_10_2022";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "fractal";
    rev = "c3d1bd7ac8c1374d887746acf614b5036ac2f95c";
    sha256 = "sha256-UzlV9MSOtCSx7RNIbr2sv4y1Kxfqo/laWJBeNiGdrZI=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    sha256 = "sha256-E0x+0vtpJATagVzpQ57hMiiTxqFR1vFM2sN7W2e17fc=";
  };

  nativeBuildInputs = [
    appstream-glib # for appstream-util
    gettext
    meson
    ninja
    pkg-config
    python3
    rustPlatform.rust.cargo
    rustPlatform.cargoSetupHook
    rustPlatform.rust.rustc
    wrapGAppsHook
    desktop-file-utils
    glib
    cmake
  ];

  buildInputs = [
    cairo
    dbus
    gdk-pixbuf
    glib
    gspell
    gst_all_1.gst-editing-services
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    (gst_all_1.gst-plugins-good.override {
      gtkSupport = true;
    })
    gst_all_1.gstreamer
    gst_all_1.gst-devtools
    gtk4
    gtksourceview5
    libadwaita
    wayland
    pipewire
    libhandy
    openssl
    libsecret
    libshumate
  ];

  # libspa-sys requires this for bindgen
  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  # <spa-0.2/spa/utils/defs.h> included by libspa-sys requires <stdbool.h>
  BINDGEN_EXTRA_CLANG_ARGS = "-I${llvmPackages.libclang.lib}/lib/clang/${lib.getVersion llvmPackages.clang}/include -I${glibc.dev}/include";

  doCheck = false;

  postPatch = ''
    patchShebangs build-aux/meson_post_install.py
  '';

  passthru = {
    updateScript = nix-update-script {
      attrPath = pname;
    };
  };

  meta = with lib; {
    description = "Matrix group messaging app";
    homepage = "https://gitlab.gnome.org/GNOME/fractal";
    license = licenses.gpl3;
    maintainers = teams.gnome.members ++ (with maintainers; [dtzWill genofire]);
  };
}
