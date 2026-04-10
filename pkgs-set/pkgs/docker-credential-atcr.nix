{
  lib,
  stdenv,
  fetchurl,
  ...
}:
let
  version = "0.0.1";
  sources = {
    "x86_64-linux" = {
      url = "https://tangled.org/evan.jarrett.net/at-container-registry/tags/v${version}/download/docker-credential-atcr_${version}_Linux_x86_64.tar.gz";
      hash = "sha256-0LYmMJapSzc5IAcqS+9Uo7MqqjsAmsRdwOCLYqM6wC8=";
    };
    "aarch64-linux" = {
      url = "https://tangled.org/evan.jarrett.net/at-container-registry/tags/v${version}/download/docker-credential-atcr_${version}_Linux_arm64.tar.gz";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  };
  source = sources.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "docker-credential-atcr";
  inherit version;

  src = fetchurl {
    inherit (source) url hash;
  };

  sourceRoot = ".";

  dontBuild = true;

  installPhase = ''
    install -m755 -D docker-credential-atcr $out/bin/docker-credential-atcr
  '';

  meta = {
    description = "Docker credential helper for AT Container Registry (atcr.io)";
    homepage = "https://atcr.io";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "docker-credential-atcr";
  };
}
