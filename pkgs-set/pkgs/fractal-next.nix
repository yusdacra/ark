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
  version = "1206d4ed12059a298b5d918fd0a77dca034f7084";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "fractal";
    rev = "1206d4ed12059a298b5d918fd0a77dca034f7084";
    sha256 = "sha256-ioMgVj85BKvsIjBbTAHFN6k5B/H86GLMTgAXK/5ji/k=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-gbTljLIYAanXm1D/tNBGNMlaDatXgZDeSY5pA8s5gog=";
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
