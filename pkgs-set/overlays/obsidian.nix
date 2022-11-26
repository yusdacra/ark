final: prev: {
  obsidian = prev.obsidian.overrideAttrs (old: {
    installPhase =
      prev.lib.replaceStrings
      ["makeWrapper ${final.electron_18}/bin/electron $out/bin/obsidian"]
      [
        ''          makeWrapper ${final.electron_20}/bin/electron $out/bin/obsidian \
                  --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland}}"''
      ]
      old.installPhase;
  });
}
