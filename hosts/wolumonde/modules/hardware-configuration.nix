{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
  ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
  # fileSystems."/mnt/data" = {
  #   device = "/dev/disk/by-id/scsi-0HC_Volume_102930299";
  #   fsType = "btrfs";
  #   options = [ "noatime" "autodefrag" "compress-force=zstd:8" ];
  # };
  # services.beesd.filesystems = {
  #   "-" = {
  #     spec = "/dev/disk/by-id/scsi-0HC_Volume_102930299";
  #     hashTableSizeMB = 48;
  #     verbosity = "crit";
  #   };
  # };
}
