{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  byLabel = label: "/dev/disk/by-label/${label}";
in {
  imports = with inputs;
  with nixos-hardware.nixosModules; [
    nixpkgs.nixosModules.notDetected
    nixos-persistence.nixosModule
    common-pc-ssd
    common-pc-laptop
    common-gpu-nvidia
    common-gpu-amd
    common-cpu-amd
    ../../modules/persist
    ../../modules/network/iwd.nix
    #../../modules/develop/nixbuild
    ../../users/root
    ../../users/patriot
  ];

  system.persistDir = "/persist";

  boot = {
    tmpOnTmpfs = true;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
    };
    kernelPackages = pkgs.linuxPackages_latest;
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

  nix.settings.max-jobs = lib.mkForce 16;
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
    allowSimultaneousMultithreading = true;
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
  services.xserver.videoDrivers = ["nvidia" "amdgpu"];
  hardware = {
    nvidia.prime = {
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    opengl = {
      driSupport = true;
      driSupport32Bit = true;
      enable = true;
      extraPackages = with pkgs; [
        libvdpau-va-gl
        vaapiVdpau
        libva
        vulkan-loader
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libvdpau-va-gl
        vaapiVdpau
        libva
        vulkan-loader
      ];
    };
    pulseaudio = {
      enable = false;
      support32Bit = true;
    };
  };

  programs.light.enable = true;

  fonts = {
    enableDefaultFonts = true;
    fontconfig.enable = true;
    fonts = [pkgs.dejavu_fonts];
  };

  environment = {
    systemPackages = [pkgs.ntfs3g];
    pathsToLink = ["/share/zsh"];
    persistence."${config.system.persistDir}" = {
      directories = lib.flatten [
        "/etc/nixos"
        (
          lib.optional
          config.virtualisation.docker.enable
          ["/var/lib/docker" "/var/lib/containers"]
        )
      ];
      files = ["/etc/machine-id"];
    };
  };

  networking.firewall.checkReversePath = "loose";
  services = {
    earlyoom.enable = true;
    tailscale.enable = false;
    ipfs = {
      enable = false;
      enableGC = true;
      autoMount = true;
    };
    flatpak.enable = false;
  };

  virtualisation = {
    waydroid.enable = false;
    podman.enable = false;
    docker.enable = true;
    libvirtd.enable = false;
  };

  system.stateVersion = "22.05";
}
