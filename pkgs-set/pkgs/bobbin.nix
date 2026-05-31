{
  lib,
  rustPlatform,
  inputs,
  ...
}:
rustPlatform.buildRustPackage {
  pname = "bobbin";
  version = "main";
 
  src = inputs.tangled;
 
  cargoHash = "sha256-uiD2U7MqfufoBJZa3oKsyhnBk4mCXo42lc18aVSLJiM=";
 
  cargoBuildFlags = [
    "--bin"
    "bobbin"
    "--package"
    "bobbin"
  ];

  postUnpack = ''
    substituteInPlace $sourceRoot/Cargo.toml \
      --replace-fail 'rust-version = "1.96"' 'rust-version = "1.95"'
  '';
 
  preBuild = ''
    export BOBBIN_LEXICONS_DIR=${inputs.tangled}/lexicons
  '';
 
  doCheck = false;
 
  meta = {
    description = "tangled appview";
    homepage = "https://tangled.org/oyster.cafe/bobbin";
    license = lib.licenses.mit;
    mainProgram = "bobbin";
  };
}