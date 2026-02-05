{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/xvda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              priority = 1;
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            esp = {
              priority = 2;
              name = "ESP";
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              priority = 3;
              end = "-908G";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
              };
            };
            plainSwap = {
              priority = 4;
              size = "8G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
            storage = {
              priority = 5;
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
              };
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "btrfs";
        device = "/dev/disk/by-uuid/c09ff0d5-7fe7-4cdd-8cad-42c475be8d99";
        mountOptions = [
          "compress-force=zstd:9"
          "noatime"
        ];
      };
    };
  };
}