{terra, ...}:
let
  llama = (terra.llama-cpp-nanbeige.override {
    vulkanSupport = true;
    blasSupport = true;
    rocmSupport = false;
    cudaSupport = false;
  }).overrideAttrs (old: {
    doCheck = false;
    cmakeFlags = (old.cmakeFlags or []) ++ ["-DGGML_AVX2=ON" "-DGGML_FMA=ON" "-DGGML_F16C=ON"];
  });
in {
  hardware.amdgpu.opencl.enable = true;

  environment.systemPackages = [llama];
}
