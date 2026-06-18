{
  lib,
  fetchurl,
  makeWrapper,
  nix-update-script,
  patchelf,
  stdenv,
  stdenvNoCC,
  unzip,

  releaseTag ? "b1291",
  gpuVariant ? "gfx110X",
  assetHash ? "sha256-BrzJZ0tU0bnrwnR6X8lVu+OimX5JBqbihKkCeDO+YcE=",
  ...
}:

let
  assetName = "llama-${releaseTag}-ubuntu-rocm-${gpuVariant}-x64.zip";
  runtimeLibPath = lib.makeLibraryPath [ stdenv.cc.cc ];
in
stdenvNoCC.mkDerivation {
  pname = "llama-cpp-rocm";
  version = lib.removePrefix "b" releaseTag;

  src = fetchurl {
    url = "https://github.com/lemonade-sdk/llamacpp-rocm/releases/download/${releaseTag}/${assetName}";
    hash = assetHash;
  };

  nativeBuildInputs = [
    makeWrapper
    patchelf
    unzip
  ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    unzip -q "$src" -d "$out/bin"

    find "$out/bin" -maxdepth 1 -type f -name 'lib*.so*' -exec chmod 0644 {} +
    find "$out/bin" -maxdepth 1 -type f ! -name 'lib*.so*' -exec chmod 0755 {} +

    find "$out/bin" -maxdepth 1 -type f -executable | while read -r prog; do
      patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" "$prog"
      wrapProgram "$prog" \
        --prefix LD_LIBRARY_PATH : "$out/bin:${runtimeLibPath}" \
        --set-default ROCBLAS_TENSILE_LIBPATH "$out/bin/rocblas/library" \
        --set-default HIPBLASLT_TENSILE_LIBPATH "$out/bin/hipblaslt/library"
    done

    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script {
      attrPath = "llama-cpp-rocm";
      extraArgs = [
        "--version-regex"
        "b(.*)"
      ];
    };
  };

  meta = {
    description = "Prebuilt llama.cpp ROCm binaries repackaged from lemonade-sdk releases";
    homepage = "https://github.com/lemonade-sdk/llamacpp-rocm";
    license = lib.licenses.mit;
    mainProgram = "llama";
    platforms = lib.platforms.linux;
  };
}
