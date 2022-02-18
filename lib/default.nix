{ lib }:
lib.makeExtensible
(
  self: {
    pkgBinNoDep = pkgs: name: "${pkgs.${name}}/bin/${name}";
    html = import ./html.nix { format = true; };
  }
)
