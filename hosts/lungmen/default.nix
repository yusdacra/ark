{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  btrfsPartPath = "/dev/disk/by-label/NIXOS";
  btrfsOptions = ["compress-force=zstd" "noatime"];
in {
  imports = with inputs;
  with nixos-hardware.nixosModules; [
    nixpkgs.nixosModules.notDetected
    nixos-persistence.nixosModule
    common-pc-ssd
    common-pc
    common-gpu-amd
    common-cpu-amd
    ../../modules/network
    #../../modules/develop/nixbuild
    ../../users/root
    ../../users/patriot
  ];

  boot = {
    tmpOnTmpfs = true;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = ["btrfs"];
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = ["amdgpu"];
    };
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
    kernel.sysctl = {"fs.inotify.max_user_watches" = 524288;};
  };

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=2G" "mode=755"];
  };
  fileSystems."/nix" = {
    device = btrfsPartPath;
    fsType = "btrfs";
    options = ["subvol=nix"] ++ btrfsOptions;
  };
  fileSystems."/persist" = {
    device = btrfsPartPath;
    fsType = "btrfs";
    options = ["subvol=persist"] ++ btrfsOptions;
    neededForBoot = true;
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };
  /*
     fileSystems."/media/archive" = {
     device = "/dev/disk/by-uuid/f9b5f7f3-51e8-4357-8518-986b16311c71";
     fsType = "btrfs";
     options = btrfsOptions;
   };
   */

  swapDevices = [];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  nix.maxJobs = lib.mkDefault 4;
  security = {
    pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "524288";
      }
      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "524288";
      }
    ];
    allowSimultaneousMultithreading = false;
    # Deleting root subvolume makes sudo show lecture every boot
    sudo.extraConfig = ''
      Defaults lecture = never
    '';
    rtkit.enable = true;
  };

  sound.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  hardware = {
    opengl = {
      driSupport = true;
      driSupport32Bit = true;
      enable = true;
      extraPackages = with pkgs; [
        libvdpau-va-gl
        vaapiVdpau
        libva
        vulkan-loader
        amdvlk
      ];
      extraPackages32 = with pkgs.pkgsi686Linux;
        [
          libvdpau-va-gl
          vaapiVdpau
          libva
          vulkan-loader
        ]
        ++ [
          pkgs.driversi686Linux.amdvlk
        ];
    };
    pulseaudio = {
      enable = false;
      support32Bit = true;
    };
  };

  fonts = {
    enableDefaultFonts = true;
    fontconfig.enable = true;
    fonts = [pkgs.dejavu_fonts];
  };

  environment = {
    systemPackages = [pkgs.ntfs3g];
    pathsToLink = ["/share/zsh"];
    persistence."/persist" = {
      directories = ["/etc/nixos"];
      files = ["/etc/machine-id"];
    };
  };

  networking.firewall.checkReversePath = "loose";
  networking.interfaces.enp6s0.useDHCP = true;
  services = {
    earlyoom.enable = true;
    tailscale.enable = false;
    ipfs = {
      enable = false;
      enableGC = true;
      autoMount = true;
    };
    flatpak.enable = false;
    xserver.videoDrivers = ["amdgpu"];
  };

  virtualisation = {
    waydroid.enable = false;
    podman.enable = false;
    libvirtd.enable = false;
  };

  system.stateVersion = "22.05";
}
