{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories = [
    ".config/ArmCord"
  ];
  home.packages = let
    flags = [
      # "--flag-switches-begin"
      # "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer"
      # "--flag-switches-end"
      # "--ozone-platform=wayland"
      # "--enable-webrtc-pipewire-capturer"
      # "--disable-gpu-memory-buffer-video-frames"
      # "--enable-accelerated-mjpeg-decode"
      # "--enable-accelerated-video"
      # "--enable-gpu-rasterization"
      # "--enable-native-gpu-memory-buffers"
      # "--enable-zero-copy"
      # "--ignore-gpu-blocklist"
    ];
    pkg =
      (pkgs.armcord.override {
        nss = pkgs.nss_latest;
      })
      .overrideAttrs (old: {
        # preInstall = ''
        #   gappsWrapperArgs+=("--add-flags" "${lib.concatStringsSep " " flags}")
        # '';
      });
  in [pkg];
  systemd.user.services.premid = {
    Install = {
      WantedBy = ["default.target"];
    };
    Unit = {
      Description = "premid";
      After = "network.target";
    };
    Service = {
      ExecStart = "${pkgs.premid}/bin/premid";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
