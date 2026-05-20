{
  lib,
  inputs,
  rustPlatform,
  ...
}:

rustPlatform.buildRustPackage {
  pname = "bobbin";
  version = "main";

  src = inputs.bobbin;

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
