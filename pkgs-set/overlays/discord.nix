{inputs}: final: prev: {
  discord-open-asar = final.callPackage "${inputs.fufexan}/pkgs/discord" {
    inherit (prev.discord) pname version src;

    openasar = prev.callPackage "${inputs.nixpkgs}/pkgs/applications/networking/instant-messengers/discord/openasar.nix" {};
    binaryName = "Discord";
    desktopName = "Discord";

    isWayland = false;
    enableVulkan = false;
    extraOptions = [
      "--disable-gpu-memory-buffer-video-frames"
      "--enable-accelerated-mjpeg-decode"
      "--enable-accelerated-video"
      "--enable-gpu-rasterization"
      "--enable-native-gpu-memory-buffers"
      "--enable-zero-copy"
      "--ignore-gpu-blocklist"
    ];
  };
}
