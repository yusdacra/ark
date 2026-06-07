{terra, ...}:
let
  llama = (terra.llama-cpp-rocm).overrideAttrs (old: {
    doCheck = false;
    cmakeFlags = (old.cmakeFlags or []) ++ ["-DGGML_AVX2=ON" "-DGGML_FMA=ON" "-DGGML_F16C=ON"];
  });
  # llama = (terra.llama-cpp.override {
  #   vulkanSupport = true;
  #   blasSupport = true;
  #   rocmSupport = false;
  #   cudaSupport = false;
  # }).overrideAttrs (old: {
  #   doCheck = false;
  #   cmakeFlags = (old.cmakeFlags or []) ++ ["-DGGML_AVX2=ON" "-DGGML_FMA=ON" "-DGGML_F16C=ON"];
  # });
in {
  hardware.amdgpu.opencl.enable = true;

  # services.llama-cpp = {
  #   enable = false;
  #   package = llama;
  #   model = "/home/mayer/models/glm-4.7-flash-q3km";
  #   host = "127.0.0.1";
  #   port = 1919;
  #   extraFlags = [
  #     "-ngl" "99"    # offload all layers to GPU
  #     "-c" "32768"   # context size
  #     "--jinja"      # needed for GLM chat template
  #   ];
  # };

  environment.systemPackages = [llama];
}
