{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
let
  version = "0.144.1";
  target = "x86_64-unknown-linux-musl";
in
stdenvNoCC.mkDerivation {
  pname = "codex";
  inherit version;

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${target}.tar.gz";
    hash = "sha256-hAka4gxl/MfUEg25fRvVfX/435x2Cft4HHjC671PWig=";
  };

  sourceRoot = ".";
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 codex-${target} $out/bin/codex
    runHook postInstall
  '';

  meta = {
    description = "OpenAI Codex CLI (prebuilt static musl binary)";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
