lib:
lib.makeExtensible (self: {
  defaultSystems = import ./systems.nix;
  genSystems = lib.genAttrs self.defaultSystems;

  pkgBin = pkg:
    if (pkg.meta or {}) ? mainProgram
    then "${pkg}/bin/${pkg.meta.mainProgram}"
    else "${pkg}/bin/${pkg.pname}";

  prefixStrings = prefix: strings:
    lib.forEach strings (string: "${prefix}${string}");

  importFolder = modules: let
    b = builtins;
    files = b.readDir modules;
    fileNames = b.attrNames files;
    filesToImport =
      b.map
      (name: "${modules}/${name}")
      (b.filter (name: b.match ".*\.nix" name != null) fileNames);
  in
    filesToImport;

  colors = import ./colors.nix lib;
})
