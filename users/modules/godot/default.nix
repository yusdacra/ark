{pkgs, ...}: {
  home.packages = with pkgs; [godot godot-headless godot-server];
}
