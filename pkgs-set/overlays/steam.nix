final: prev: {
  steam = prev.steam.override {
    extraLibraries = pkgs: with pkgs; [mimalloc pipewire vulkan-loader wayland wayland-protocols];
    # extraProfile = ''
    #   unset VK_ICD_FILENAMES
    #   export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d:/run/opengl-driver-32/share/vulkan/icd.d"
    # '';
  };
}
