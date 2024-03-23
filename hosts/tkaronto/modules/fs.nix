{config, ...}: let
  byLabel = label: "/dev/disk/by-label/${label}";
  f2fsOptions = ["compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime"];
in {
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=2G" "mode=755"];
  };
  fileSystems."/nix" = {
    device = byLabel "NIX";
    fsType = "f2fs";
    options = f2fsOptions;
  };
  fileSystems."${config.system.persistDir}" = {
    device = byLabel "PERSIST";
    fsType = "f2fs";
    neededForBoot = true;
    options = f2fsOptions;
  };
  fileSystems."/boot" = {
    device = byLabel "BOOT";
    fsType = "vfat";
  };

  swapDevices = [];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
}
