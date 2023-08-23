{lib, ...}: let
  l = lib // builtins;
  mkRule = name: type: {
    inherit name type;
  };
in {
  services.ananicy = {
    enable = true;
    extraRules = [
      # coompilers
      (mkRule "g++" "BG_CPUIO")
      (mkRule "gcc" "BG_CPUIO")
      (mkRule "clang" "BG_CPUIO")
      (mkRule "mold" "BG_CPUIO")
      (mkRule "ld" "BG_CPUIO")
      (mkRule "gold" "BG_CPUIO")
      (mkRule "rustc" "BG_CPUIO")
      (mkRule "zig" "BG_CPUIO")
      (mkRule "cargo" "BG_CPUIO")
      (mkRule "rust-analyzer" "BG_CPUIO")
      (mkRule "go" "BG_CPUIO")
      (mkRule "nix" "BG_CPUIO")
      (mkRule "nix-daemon" "BG_CPUIO")
      # editors
      (mkRule "hx" "Doc-View")
      (mkRule ".hx-wrapped" "Doc-View")
      # browser
      (mkRule "firefox" "Doc-View")
      (mkRule ".firefox-wrapped" "Doc-View")
      (mkRule "chromium" "Doc-View")
      (mkRule ".chromium-wrapped" "Doc-View")
      # wm
      (mkRule ".gnome-shell-wrapped" "LowLatency_RT")
      (mkRule "gnome-shell" "LowLatency_RT")
      (mkRule "Hyprland" "LowLatency_RT")
      (mkRule "sway" "LowLatency_RT")
      (mkRule ".sway-wrapped" "LowLatency_RT")
      (mkRule "rofi" "LowLatency_RT")
      (mkRule ".rofi-wrapped" "LowLatency_RT")
      (mkRule "wlsunset" "BG_CPUIO")
      (mkRule "swayidle" "BG_CPUIO")
      # term
      (mkRule "wezterm-gui" "Doc-View")
      (mkRule "foot" "Doc-View")
      (mkRule "gnome-terminal" "Doc-View")
      (mkRule ".gnome-terminal-wrapped" "Doc-View")
      # other
      (mkRule "syncthing" "BG_CPUIO")
    ];
  };
}
