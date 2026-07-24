{
  lib,
  llama-cpp,
  fetchFromGitHub,
  vulkanSupport ? true,
  rocmSupport ? false,
  cudaSupport ? false,
  openclSupport ? false,
  blasSupport ? true,
  ...
}:

(llama-cpp.override {
  inherit
    vulkanSupport
    rocmSupport
    cudaSupport
    openclSupport
    blasSupport
    ;
}).overrideAttrs (oldAttrs: {
  pname = "llama-cpp-nanbeige";
  version = "42";

  src = fetchFromGitHub {
    owner = "Nanbeige";
    repo = "llama.cpp";
    rev = "03327d628ad6db847d28a330636ffbd845030e29";
    hash = "sha256-20BZ5zqsOM9fq5ttiRSv+nTq2jKqegKHL0pg3fED/CM=";
  };

  npmRoot = "";
  npmDeps = "";
  npmDepsHash = "";

  nativeBuildInputs = lib.filter (
    p: !(lib.hasPrefix "nodejs" (p.name or "")) && !(lib.hasPrefix "npm-config-hook" (p.name or ""))
  ) oldAttrs.nativeBuildInputs;

  postPatch = ''
    echo "03327d6" > COMMIT
  '';

  preConfigure = ''
    prependToVar cmakeFlags "-DLLAMA_BUILD_COMMIT:STRING=$(cat COMMIT)"
  '';
})
