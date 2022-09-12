{pkgs, lib, ...}:
let
  l = lib // builtins;
  mkRule = name: type: l.toJSON {
    inherit name type;
  };
in
{
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    extraRules = l.concatStringsSep "\n" [
      # coompilers
      (mkRule "g++" "BG_CPUIO")
      (mkRule "gcc" "BG_CPUIO")
      (mkRule "clang" "BG_CPUIO")
      (mkRule "mold" "BG_CPUIO")
      (mkRule "ld" "BG_CPUIO")
      (mkRule "gold" "BG_CPUIO")
      (mkRule "rustc" "BG_CPUIO")
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
      # wm
      (mkRule "Hyprland" "LowLatency_RT")
      (mkRule "rofi" "LowLatency_RT")
      (mkRule "wlsunset" "BG_CPUIO")
      (mkRule "swayidle" "BG_CPUIO")
      # term
      (mkRule "wezterm-gui" "Doc-View")
      # other
      (mkRule "syncthing" "BG_CPUIO")
    ];
  };
}
