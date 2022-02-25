_: prev: let
  pkgs = prev;
  lib = pkgs.lib;
  vscodeWayland =
    let
      flags = [
        "--flag-switches-begin"
        "--enable-features=UseOzonePlatform,IgnoreGPUBlocklist"
        "--flag-switches-end"
        "--ozone-platform=wayland"
        "--ignore-gpu-blocklist"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
        "--disable-gpu-driver-bug-workarounds"
      ];
    in
      pkgs.writeScriptBin
      "vscode-wayland"
      ''
        #!${pkgs.stdenv.shell}
        ${pkgs.vscodium}/bin/codium ${lib.concatStringsSep " " flags}
      '';
in {
  vscodeWayland =
    let
      pname = "vscode";
      desktop =
        pkgs.makeDesktopItem
        {
          name = pname;
          exec = pname;
          icon = "vscode";
          desktopName = "VSCode Wayland";
        };
    in
      lib.hiPrio
      (
        pkgs.stdenv.mkDerivation
        {
          inherit pname;
          version = pkgs.vscode.version;
          nativeBuildInputs = [pkgs.makeWrapper];
          phases = ["installPhase"];
          installPhase =
            ''
              mkdir -p $out/bin
              install -m755 ${vscodeWayland}/bin/${pname}-wayland $out/bin/${pname}
              cp -r ${desktop}/share $out/share
            '';
        }
      );
}
