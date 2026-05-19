{
  lib,
  rustPlatform,
  fetchgit,
  pkg-config,
  perl,
  openssl,
  zstd,
  ...
}:

rustPlatform.buildRustPackage rec {
  pname = "slingshot";
  version = "2c3a9bf03f0e413f71442896ce6e8f5ea298a7a4";

  src = fetchgit {
    url = "https://tangled.org/microcosm.blue/microcosm-rs";
    rev = version;
    hash = "sha256-U5Sj8CfQKvlgSHyGN+JT34PIQL1VYPIrPN+M88y0Y6k=";
  };

  cargoHash = "sha256-G5GDTfsHeO302R/YKKJnjBjEeDKc0wb+ghIt+GyssaE=";

  cargoBuildFlags = [
    "--package"
    "slingshot"
  ];

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  buildInputs = [
    openssl
    zstd
  ];

  doCheck = false;

  meta = {
    description = "atproto record edge cache";
    homepage = "https://tangled.org/microcosm.blue/microcosm-rs";
    license = with lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "slingshot";
  };
}
