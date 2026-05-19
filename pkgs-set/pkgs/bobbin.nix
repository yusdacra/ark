{
  lib,
  inputs,
  rustPlatform,
  fetchzip,
  ...
}:

rustPlatform.buildRustPackage rec {
  pname = "bobbin";
  version = "05df522f1fd2babc3540e2652c6ed348221612dd";

  src = fetchzip {
    url = "https://tangled.org/oyster.cafe/bobbin/archive/${version}.tar.gz";
    hash = "sha256-ly9q9gVXfzvl1FRhGYFK7XYkybUdH4PLccqHqXQwcHk=";
    stripRoot = false;
  };

  cargoHash = "sha256-Ojy5LZvyM3J+0zwMn96G/K2XXpj5ASM7ho5Y3Xj8Apg=";

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'rust-version = "1.95"' 'rust-version = "1.94"'
  '';

  cargoBuildFlags = [
    "--bin"
    "bobbin"
    "--package"
    "bobbin"
  ];

  preBuild = ''
    export BOBBIN_LEXICONS_DIR=${inputs.tangled}/lexicons
  '';

  doCheck = false;

  meta = {
    description = "Tangled graph edge index and XRPC service";
    homepage = "https://tangled.org/oyster.cafe/bobbin";
    license = lib.licenses.mit;
    mainProgram = "bobbin";
  };
}
