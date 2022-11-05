{config, ...}: {
  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories = [".config/chromium"];
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--enable-features=WaylandWindowDecorations"
      "--enable-crashpad"
      "--flag-switches-begin"
      "--enable-gpu-rasterization"
      "--enable-unsafe-webgpu"
      "--enable-zero-copy"
      "--ignore-gpu-blocklist"
      "--disable-gpu-driver-bug-workarounds"
      "--ozone-platform-hint=wayland"
      "--enable-features=SystemNotifications,WaylandWindowDecorations,CanvasOopRasterization,EnableDrDc,RawDraw,WebRTCPipeWireCapturer"
      "--disable-features=Vulkan"
      "--flag-switches-end"
      "--disk-cache-dir=\"$XDG_RUNTIME_DIR/chromium-cache\""
      "--process-per-site"
    ];
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "nngceckbapebfimnlniiiahkandclblb" # bitwarden
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
      "hlepfoohegkhhmjieoechaddaejaokhf" # refined github
      "annfbnbieaamhaimclajlajpijgkdblo" # dark theme
    ];
  };
}
