{config, ...}: {
  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories = [
    ".config/chromium"
    ".local/share/applications"
  ];
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--flag-switches-begin"
      "--enable-webrtc-pipewire-capturer"
      "--disable-software-rasterizer"
      "--disable-gpu-driver-workarounds"
      "--enable-accelerated-video-decode"
      "--enable-accelerated-mjpeg-decode"
      "--enable-gpu-compositing"
      "--enable-oop-rasterization"
      "--canvas-oop-rasterization"
      "--enable-raw-draw"
      "--enable-zero-copy"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--ignore-gpu-blocklist"
      "--disable-gpu-driver-bug-workarounds"
      "--ozone-platform-hint=wayland"
      "--enable-features=SystemNotifications,WaylandWindowDecorations,WebRTCPipeWireCapturer,EnableDrDc,CanvasOopRasterization,RawDraw,VaapiVideoDecoder,UseSkiaRenderer"
      "--flag-switches-end"
      "--disk-cache-dir=\"$XDG_RUNTIME_DIR/chromium-cache\""
    ];
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "nngceckbapebfimnlniiiahkandclblb" # bitwarden
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
      "hlepfoohegkhhmjieoechaddaejaokhf" # refined github
      "annfbnbieaamhaimclajlajpijgkdblo" # dark theme
      "nblkbiljcjfemkfjnhoobnojjgjdmknf" # pronoundb
    ];
  };
}
