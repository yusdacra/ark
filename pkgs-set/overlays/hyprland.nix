{inputs}: final: prev: {
  hyprland = inputs.hyprland.packages.${prev.system}.default;
}
