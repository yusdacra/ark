final: prev: {
  spotify =
    final.runCommand prev.spotify.name {
      inherit (prev.spotify) meta;
      nativeBuildInputs = [final.makeWrapper];
    } ''
      shopt -s extglob
      mkdir -p $out/bin
      ln -sf ${prev.spotify}/!(bin) $out/
      ln -sf ${prev.spotify}/bin/* $out/bin/
      wrapProgram $out/bin/spotify \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland}}"
    '';
}
