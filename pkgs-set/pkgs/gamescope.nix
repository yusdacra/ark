{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  pkgconfig,
  libdrm,
  xorg,
  wayland,
  wayland-protocols,
  libxkbcommon,
  libcap,
  SDL2,
  mesa,
  libinput,
  pixman,
  xcbutilerrors,
  xcbutilwm,
  glslang,
  ninja,
  makeWrapper,
  xwayland,
  libuuid,
  xcbutilrenderutil,
  pipewire,
  stb,
  writeText,
  wlroots,
  vulkan-loader,
  vulkan-headers,
  libseat,
  ...
}: let
  stbpc = writeText "stbpc" ''
    prefix=${stb}
    includedir=''${prefix}/include/stb
    Cflags: -I''${includedir}
    Name: stb
    Version: ${stb.version}
    Description: stb
  '';
  stb_ = stb.overrideAttrs (oldAttrs: rec {
    installPhase = ''
      ${oldAttrs.installPhase}
      install -Dm644 ${stbpc} $out/lib/pkgconfig/stb.pc
    '';
  });
in
  stdenv.mkDerivation rec {
    pname = "gamescope";
    version = "3.11.30";

    src = fetchFromGitHub {
      owner = "Plagman";
      repo = "gamescope";
      rev = version;
      sha256 = "sha256-dSQrOlQfUZkA8Vrc/Tj9dAWIIBOeb+tAen21fZe3Gto=";
      fetchSubmodules = true;
    };

    postInstall = ''
      wrapProgram $out/bin/gamescope \
        --prefix PATH : "${lib.makeBinPath [xwayland]}"
    '';

    buildInputs = with xorg; [
      libX11
      libXdamage
      libXcomposite
      libXrender
      libXext
      libXxf86vm
      libXtst
      libdrm
      vulkan-loader
      wayland
      wayland-protocols
      libxkbcommon
      libcap
      SDL2
      mesa
      libinput
      pixman
      xcbutilerrors
      xcbutilwm
      libXi
      libXres
      libuuid
      xcbutilrenderutil
      xwayland
      pipewire
      wlroots
      libseat
    ];
    nativeBuildInputs = [meson pkgconfig glslang ninja makeWrapper stb_];

    meta = with lib; {
      description = "The micro-compositor formerly known as steamcompmgr";
      license = licenses.bsd2;
      homepage = src.meta.homepage;
      platforms = platforms.linux;
      maintainers = with maintainers; [];
    };
  }
