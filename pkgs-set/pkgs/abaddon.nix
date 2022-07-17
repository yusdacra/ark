{
  stdenv,
  fetchFromGitHub,
  gtkmm3,
  sqlite,
  openssl,
  curlWithGnuTls,
  nlohmann_json,
  pkg-config,
  cmake,
  ...
}:
stdenv.mkDerivation rec {
  pname = "abaddon";
  version = "ccf5afbba959068f34897b75afcd25c65c96d79c";

  src = fetchFromGitHub {
    owner = "uowuo";
    repo = pname;
    rev = version;
    sha256 = "sha256-PKEly2yBM6UKNi/XEEUvbpTmvNSNJM1lUVMovCHgi50=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    gtkmm3.dev
    curlWithGnuTls.dev
    sqlite.dev
    openssl
    nlohmann_json
  ];

  configurePhase = "mkdir build && cd build && cmake ..";
  installPhase = "mkdir -p $out/bin && mv abaddon $out/bin/abaddon";

  doCheck = false;
}
