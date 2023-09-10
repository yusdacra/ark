{pkgs, ...}: {
  boot = {
    tmp.useTmpfs = true;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
    };
    kernelPackages = pkgs.linuxPackages_zen;
    supportedFilesystems = ["f2fs"];
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = ["amdgpu"];
    };
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
    kernel.sysctl = {"fs.inotify.max_user_watches" = 524288;};
  };
}
