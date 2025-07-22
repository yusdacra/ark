{
  inputs,
  system,
  lib,
  tlib,
  ...
}:
let
  l = lib // builtins;
  overlays = l.flatten (
    l.mapAttrsToList
    (
      name: _:
        if name != "disabled"
        then
          let
            o = import "${./overlays}/${name}";
          in
          if (l.functionArgs o) ? inputs
          then o { inherit inputs; }
          else o
        else
          []
    )
    (l.readDir ./overlays)
  );
  pkgs = import inputs.nixpkgs {
    inherit system overlays;
    config.allowUnfree = true;
    # config.allowBroken = true;
    # config.permittedInsecurePackages = ["electron-25.9.0"];
  };
  terraPkgs =
    l.genAttrs
    (l.map (l.removeSuffix ".nix") (l.attrNames (l.readDir ./pkgs)))
    (name: pkgs.callPackage "${./pkgs}/${name}.nix" {
      inherit inputs tlib;
    });
  pkgsToExport = pkgs.lib.getAttrs (import ./exported.nix) (pkgs // terraPkgs);
in {
  inherit pkgs;
  terra = terraPkgs;
  exported = pkgsToExport;
}
