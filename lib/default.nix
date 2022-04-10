lib:
lib.makeExtensible (self: {
  defaultSystems = import ./systems.nix;
  genSystems = lib.genAttrs self.defaultSystems;

  pkgBin = pkgs: id:
    if lib.isString id
    then "${pkgs.${id}}/bin/${id}"
    else "${pkgs.${id.name}}/bin/${id.bin}";
})
