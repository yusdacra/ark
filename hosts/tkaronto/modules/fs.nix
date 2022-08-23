{config, ...}: let
  byLabel = label: "/dev/disk/by-label/${label}";
in {
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=2G" "mode=755"];
  };
  fileSystems."/nix" = {
    device = byLabel "NIX";
    fsType = "f2fs";
  };
  fileSystems."${config.system.persistDir}" = {
    device = byLabel "PERSIST";
    fsType = "f2fs";
    neededForBoot = true;
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
