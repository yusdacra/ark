{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories = [
    ".config/WebCord"
  ];
  home.packages = let
    pkg = inputs.webcord.packages.${pkgs.system}.webcord;
  in [
    (
      pkgs.runCommand pkg.name {nativeBuildInputs = [pkgs.makeWrapper];} ''
        mkdir -p $out
        ln -sf ${pkg}/* $out/
        rm $out/bin
        mkdir $out/bin
        ln -s ${pkg}/bin/webcord $out/bin/webcord
        wrapProgram $out/bin/webcord \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [pkgs.pipewire]}"
      ''
    )
  ];
}
