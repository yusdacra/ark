_: prev: let
  cliArgs = let
    flags = [
      "--flag-switches-begin"
      "--enable-features=WebUIDarkMode,UseOzonePlatform,WebRTCPipeWireCapturer,IgnoreGPUBlocklist"
      "--flag-switches-end"
      "--ozone-platform=wayland"
      "--enable-webrtc-pipewire-capturer"
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--disable-gpu-driver-bug-workarounds"
      "--force-dark-mode"
    ];
  in
    prev.lib.concatStringsSep " " flags;
in {chromium = prev.chromium.override {commandLineArgs = cliArgs;};}