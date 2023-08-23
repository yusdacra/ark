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
      # "--force-dark-mode"
      # "--enable-gpu-rasterization"
      # "--enable-zero-copy"
      # "--ignore-gpu-blocklist"
      # "--disable-gpu-driver-bug-workarounds"
      "--ozone-platform-hint=wayland"
      "--enable-features=SystemNotifications,WaylandWindowDecorations,WebRTCPipeWireCapturer"
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
