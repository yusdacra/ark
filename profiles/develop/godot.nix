{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    godot-bin
    godot-headless-bin
    godot-server-bin
  ];
}
