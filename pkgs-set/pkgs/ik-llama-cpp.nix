{
  lib,
  autoAddDriverRunpath,
  cmake,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  stdenv,

  config,
  cudaSupport ? config.cudaSupport or false,
  cudaPackages ? { },

  rocmSupport ? config.rocmSupport or false,
  rocmPackages ? { },
  rocmGpuTargets ? rocmPackages.clr.localGpuTargets or rocmPackages.clr.gpuTargets or [],

  openclSupport ? false,
  clblast,

  blasSupport ? builtins.all (x: !x) [
    cudaSupport
    metalSupport
    openclSupport
    rocmSupport
    vulkanSupport
  ],
  blas,

  fetchNpmDeps,
  nodejs,
  npmHooks,

  pkg-config,
  metalSupport ? stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64 && !openclSupport,
  vulkanSupport ? false,
  rpcSupport ? false,
  openssl,
  shaderc,
  vulkan-headers,
  vulkan-loader,
  ninja,

  # -march=native is non-deterministic; override with platform-specific flags if needed
  native ? false,

  ...
}:

let
  # It's necessary to consistently use backendStdenv when building with CUDA support,
  # otherwise we get libstdc++ errors downstream.
  # cuda imposes an upper bound on the gcc version
  effectiveStdenv = if cudaSupport then cudaPackages.backendStdenv else stdenv;
  inherit (lib)
    cmakeBool
    cmakeFeature
    optionals
    optionalString
    ;

  cudaBuildInputs = with cudaPackages; [
    cuda_cccl # <nv/target>

    # A temporary hack for reducing the closure size, remove once cudaPackages
    # have stopped using lndir: https://github.com/NixOS/nixpkgs/issues/271792
    cuda_cudart
    libcublas
  ];

  rocmBuildInputs = with rocmPackages; [
    clr
    hipblas
    rocblas
  ];

  vulkanBuildInputs = [
    shaderc
    vulkan-headers
    vulkan-loader
  ];
in
effectiveStdenv.mkDerivation (finalAttrs: {
  pname = "ik-llama-cpp";
  version = "1744-pr";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "SamuelOliveirads";
    repo = "ik_llama.cpp";
    rev = "a703033607ed3edbeab0205d8c9ad75cc1b5759f";
    hash = "sha256-737rn0o8pnFYMZuhWFvs0TE4JfPlU4ueTKj67JUO5nE=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse --short HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  patches = [ ];

  postPatch = ''
    # We will try building without webui for now since sass-embedded is a pain in Nix
    # and users usually want the server binary for API access anyway.
    # If they really want the UI, we can try more hacks later.
    rm -rf examples/server/webui
  '';

  nativeBuildInputs = [
    cmake
    installShellFiles
    ninja
    pkg-config
  ]
  ++ optionals cudaSupport [
    cudaPackages.cuda_nvcc
    autoAddDriverRunpath
  ];

  buildInputs =
    optionals cudaSupport cudaBuildInputs
    ++ optionals openclSupport [ clblast ]
    ++ optionals rocmSupport rocmBuildInputs
    ++ optionals blasSupport [ blas ]
    ++ optionals vulkanSupport vulkanBuildInputs
    ++ [ openssl ];

  preConfigure = ''
    prependToVar cmakeFlags "-DLLAMA_BUILD_COMMIT:STRING=$(cat COMMIT)"
  '';

  cmakeFlags = [
    (cmakeBool "GGML_NATIVE" native)
    (cmakeBool "LLAMA_BUILD_EXAMPLES" true)
    (cmakeBool "LLAMA_BUILD_SERVER" true)
    (cmakeBool "LLAMA_BUILD_TESTS" (finalAttrs.finalPackage.doCheck or false))
    (cmakeBool "LLAMA_OPENSSL" true)
    (cmakeBool "BUILD_SHARED_LIBS" true)
    (cmakeBool "GGML_BLAS" blasSupport)
    (cmakeBool "GGML_CLBLAST" openclSupport)
    (cmakeBool "GGML_CUDA" cudaSupport)
    (cmakeBool "GGML_HIP" rocmSupport)
    (cmakeBool "GGML_METAL" metalSupport)
    (cmakeBool "GGML_RPC" rpcSupport)
    (cmakeBool "GGML_VULKAN" vulkanSupport)
    (cmakeFeature "LLAMA_BUILD_NUMBER" finalAttrs.version)
  ]
  ++ optionals cudaSupport [
    (cmakeFeature "CMAKE_CUDA_ARCHITECTURES" cudaPackages.flags.cmakeCudaArchitecturesString)
  ]
  ++ optionals rocmSupport [
    (cmakeFeature "CMAKE_HIP_COMPILER" "''${rocmPackages.clr.hipClangPath}/clang++")
    (cmakeFeature "CMAKE_HIP_ARCHITECTURES" (builtins.concatStringsSep ";" rocmGpuTargets))
  ]
  ++ optionals metalSupport [
    (cmakeFeature "CMAKE_C_FLAGS" "-D__ARM_FEATURE_DOTPROD=1")
    (cmakeBool "LLAMA_METAL_EMBED_LIBRARY" true)
  ]
  ++ optionals rpcSupport [
    # This is done so we can move rpc-server out of bin because llama.cpp doesn't
    # install rpc-server in their install target.
    (cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
  ];

  # upstream plans on adding targets at the cmakelevel, remove those
  # additional steps after that
  postInstall = ''
    # Match previous binary name for this package
    # In ik_llama.cpp fork, the server binary might be named llama-server
    # Let's check if it exists before symlinking
    if [ -f $out/bin/llama-server ]; then
      ln -sf $out/bin/llama-server $out/bin/llama
    fi

    mkdir -p $out/include
    cp $src/include/llama.h $out/include/

  ''
  + optionalString rpcSupport "cp bin/rpc-server $out/bin/llama-rpc-server";

  # the tests are failing as of 2025-08
  doCheck = false;

  meta = {
    description = "Inference of Meta's LLaMA model (and others) in pure C/C++ (ikawrakow fork, PR 1744)";
    homepage = "https://github.com/SamuelOliveirads/ik_llama.cpp";
    license = lib.licenses.mit;
    mainProgram = "llama";
    platforms = lib.platforms.unix;
    badPlatforms = optionals (cudaSupport || openclSupport) lib.platforms.darwin;
    broken = metalSupport && !effectiveStdenv.hostPlatform.isDarwin;
  };
})
