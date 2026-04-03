{pkgs, ...}:
let
  llama = (pkgs.llama-cpp.overrideAttrs (prev: {
    cmakeFlags = prev.cmakeFlags ++ [ "-DAMDGPU_TARGETS=gfx1102" ]; # rx 7600 xt
  })).override {
    rocmSupport = true;
    cudaSupport = false;
    openclSupport = false;
    vulkanSupport = false;
  };
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