{ lib }:
lib.makeExtensible (self: {
  pkgBinNoDep = pkgs: name: "${pkgs.${name}}/bin/${name}";
})
