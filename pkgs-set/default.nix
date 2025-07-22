{
  flakeInputs,
  system,
  lib,
  tlib,
  ...
}:
let
  l = lib // builtins;
  _pkgs = import flakeInputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    # config.allowBroken = true;
    # config.permittedInsecurePackages = ["electron-25.9.0"];
  };
  _inputs = import ../_sources/generated.nix {
    inherit (_pkgs) fetchgit fetchurl fetchFromGitHub dockerTools;
  };
  inputs = (l.mapAttrs (_: inp: inp // {__toString = s: toString s.src;}) _inputs) // flakeInputs;
  pkgs = _pkgs.appendOverlays (
    l.flatten (
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
    )
  );
  terraPkgs =
    pkgs.lib.makeScope pkgs.newScope (
      self:
        l.genAttrs
        (l.map (l.removeSuffix ".nix") (l.attrNames (l.readDir ./pkgs)))
        (name: self.callPackage "${./pkgs}/${name}.nix" {
          inherit inputs tlib;
        })
    );
  pkgsToExport = pkgs.lib.getAttrs (import ./exported.nix) (pkgs // terraPkgs);
in {
  inherit pkgs inputs;
  terra = terraPkgs;
  exported = pkgsToExport;
}
