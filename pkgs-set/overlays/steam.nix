{inputs}:
final: prev: {
  steam = prev.steam.override {
    extraLibraries = pkgs: with pkgs; [mimalloc pipewire vulkan-loader wayland wayland-protocols];
    extraProfile = ''
      PATH="$PATH:${inputs.fufexan.packages.${prev.system}.gamescope}/bin"
    '';
  };
}
