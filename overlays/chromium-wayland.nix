_: prev:
let
  pkgs = prev;
  lib = pkgs.lib;
  chromiumWayland =
    let
      flags = [
        "--enable-vulkan"
        "--flag-switches-begin"
        "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,IgnoreGPUBlocklist,Vulkan"
        "--flag-switches-end"
        "--ozone-platform=wayland"
        "--enable-webrtc-pipewire-capturer"
        "--ignore-gpu-blocklist"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
        "--disable-gpu-driver-bug-workarounds"
      ];
    in
    pkgs.writeScriptBin "chromium-wayland" ''
      #!${pkgs.stdenv.shell}
      ${pkgs.chromium}/bin/chromium ${lib.concatStringsSep " " flags}
    '';
in
{
  chromiumWayland =
    let
      pname = "chromium";
      desktop = pkgs.makeDesktopItem {
        name = pname;
        exec = pname;
        icon = "chromium-browser";
        desktopName = "Chromium Wayland";
        genericName = "Web Browser";
      };
    in
    lib.hiPrio (pkgs.stdenv.mkDerivation {
      inherit pname;
      version = pkgs.chromium.version;

      nativeBuildInputs = [ pkgs.makeWrapper ];
      phases = [ "installPhase" "fixupPhase" ];
      installPhase = ''
        mkdir -p $out/bin
        install -m755 ${chromiumWayland}/bin/${pname}-wayland $out/bin/${pname}
        cp -r ${desktop}/share $out/share
      '';
      /*fixupPhase = ''
        wrapProgram $out/bin/${name} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (with pkgs; [ vulkan-loader libGL ])}
        '';*/
    });
}
