lib:
(lib.extend (_: _: builtins)).extend (_: lib: rec {
  defaultSystems = import ./systems.nix;
  genSystems = lib.genAttrs defaultSystems;

  pkgBin = pkgs: id:
    if lib.isString id
    then "${pkgs.${id}}/bin/${id}"
    else "${pkgs.${id.name}}/bin/${id.bin}";
})
