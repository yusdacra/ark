{inputs}: final: prev: {
  steam = prev.steam.override {
    extraLibraries = pkgs: with pkgs; [mimalloc pipewire vulkan-loader wayland wayland-protocols];
  };
}
