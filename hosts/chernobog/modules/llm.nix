{terra, pkgs, ...}:
let
  llama = (terra.llama-cpp.override {
    rocmSupport = false;
    cudaSupport = false;
    openclSupport = false;
    blasSupport = false;
    vulkanSupport = true;
    native = true;
  }).overrideAttrs (old: {
    doCheck = false;
  });
  # llama = pkgs.stdenv.mkDerivation {
  #   name = "llamacpp-rocm-b1229";

  #   src = pkgs.fetchurl {
  #     url = "https://github.com/lemonade-sdk/llamacpp-rocm/releases/download/b1229/llama-b1229-ubuntu-rocm-gfx110X-x64.zip";
  #     hash = "sha256-RGKGfZ3HBssBhFaskb8IAQYMng+K4Fol7J0H5rCmgwA=";
  #   };
  #   sourceRoot = ".";

  #   nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.makeBinaryWrapper pkgs.unzip ];
  #   buildInputs = [ pkgs.stdenv.cc.cc.lib ]; # just glibc/libstdc++

  #   installPhase = ''
  #     mkdir -p $out/bin $out/lib/rocblas
  #     cp *.so* $out/lib || true
  #     cp llama-* $out/bin
  #     chmod +x $out/bin/*
  #     ln -sf ${pkgs.rocmPackages.rocblas}/lib/rocblas/library $out/lib/rocblas/library
  #   '';

  #   autoPatchelfIgnoreMissingDeps = true;
  # };
in {
  # services.ollama = {
  #   enable = true;
  #   package = pkgs.ollama-rocm;
  #   rocmOverrideGfx = "11.0.0";
  # };

  services.llama-cpp = {
    enable = false;
    package = llama;
    model = "/home/mayer/models/glm-4.7-flash-q3km";
    host = "127.0.0.1";
    port = 1919;
    extraFlags = [
      "-ngl" "99"    # offload all layers to GPU
      "-c" "32768"   # context size
      "--jinja"      # needed for GLM chat template
    ];
  };

  environment.systemPackages = [llama];
}