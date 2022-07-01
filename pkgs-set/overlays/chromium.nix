_: prev: let
  flags = [
    "--ignore-gpu-blocklist"
    "--disable-gpu-driver-bug-workarounds"
    "--enable-features=WebUIDarkMode"
    "--enable-gpu-rasterization"
    "--enable-zero-copy"
    "--force-dark-mode"
    "--enable-webrtc-pipewire-capturer"
    "--ozone-platform-hint=auto"
  ];
  mkCliArgs = flags: prev.lib.concatStringsSep " " flags;
in {
  chromium = prev.chromium.override {commandLineArgs = mkCliArgs flags;};
}
