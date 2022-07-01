{lib, ...}: {
  options.system.persistDir = lib.mkOption {
    type = lib.types.str;
  };
}
