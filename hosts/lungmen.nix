{ config, lib, pkgs, modulesPath, suites, ... }:
let
  btrfsPartPath = "/dev/disk/by-label/NIXOS";
  btrfsOptions = [ "compress-force=zstd" "noatime" ];

  btrfsDiff = pkgs.writeScriptBin "btrfs-diff" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    sudo mkdir -p /mnt
    sudo mount -o subvol=/ ${btrfsPartPath} /mnt

    OLD_TRANSID=$(sudo btrfs subvolume find-new /mnt/root-blank 9999999)

    sudo btrfs subvolume find-new "/mnt/root" "$OLD_TRANSID" |
    sed '$d' |
    cut -f17- -d' ' |
    sort |
    uniq |
    while read path; do
      path="/$path"
      if [ -L "$path" ]; then
        : # The path is a symbolic link, so is probably handled by NixOS already
      elif [ -d "$path" ]; then
        : # The path is a directory, ignore
      else
        echo "$path"
      fi
    done

    sudo umount /mnt
  '';
in
{
  imports = suites.base ++ suites.work ++ [
    ../profiles/network/networkmanager
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "btrfs" ];
    initrd = {
      availableKernelModules =
        [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "amdgpu" ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    initrd.postDeviceCommands = pkgs.lib.mkBefore ''
      mkdir -p /mnt
      mount -o subvol=/ ${btrfsPartPath} /mnt
      btrfs subvolume list -o /mnt/root |
      cut -f9 -d' ' |
      while read subvolume; do
        echo "deleting /$subvolume subvolume..."
        btrfs subvolume delete "/mnt/$subvolume"
      done &&
      echo "deleting /root subvolume..." &&
      btrfs subvolume delete /mnt/root
      echo "restoring blank /root subvolume"
      btrfs subvolume snapshot /mnt/root-blank /mnt/root
      umount /mnt
    '';
    kernel.sysctl = {
      "fs.inotify.max_user_watches" = 524288;
    };
  };

  fileSystems."/" = {
    device = btrfsPartPath;
    fsType = "btrfs";
    options = [ "subvol=root" ] ++ btrfsOptions;
  };

  fileSystems."/home" = {
    device = btrfsPartPath;
    fsType = "btrfs";
    options = [ "subvol=home" ] ++ btrfsOptions;
  };

  fileSystems."/media/archive" = {
    device = "/dev/disk/by-uuid/f9b5f7f3-51e8-4357-8518-986b16311c71";
    fsType = "btrfs";
    options = btrfsOptions;
  };

  fileSystems."/nix" = {
    device = btrfsPartPath;
    fsType = "btrfs";
    options = [ "subvol=nix" ] ++ btrfsOptions;
  };

  fileSystems."/persist" = {
    device = btrfsPartPath;
    fsType = "btrfs";
    options = [ "subvol=persist" ] ++ btrfsOptions;
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5784-BBB1";
    fsType = "vfat";
  };

  swapDevices = [ ];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  nix.maxJobs = lib.mkDefault 4;

  security = {
    mitigations.disable = true;
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
        amdvlk
        libvdpau-va-gl
        vaapiVdpau
        libva
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
      ];
      extraPackages32 = with pkgs.pkgsi686Linux;
        [
          libvdpau-va-gl
          vaapiVdpau
          libva
          vulkan-loader
          vulkan-validation-layers
          vulkan-extension-layer
        ]
        ++ [ pkgs.driversi686Linux.amdvlk ];
    };
    pulseaudio = {
      enable = false;
      support32Bit = true;
    };
  };


  environment = {
    systemPackages = [ btrfsDiff ];
    pathsToLink = [ "/share/zsh" ];
    persistence."/persist" = {
      directories = [ "/etc/nixos" ];
      files = [ "/etc/machine-id" ];
    };
    sessionVariables = {
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json";
      LD_LIBRARY_PATH = lib.mkForce "${lib.makeLibraryPath (config.hardware.opengl.extraPackages ++ config.hardware.opengl.extraPackages32)}";
    };
  };
  networking.interfaces.enp6s0.useDHCP = true;

  services = {
    ipfs = {
      enable = false;
      enableGC = true;
      autoMount = true;
    };
    flatpak.enable = false;
    xserver = {
      videoDrivers = [ "amdgpu" ];
    };
    postgresql = {
      enable = false;
      enableTCPIP = true;
      authentication = lib.mkOverride 10 ''
        local all all trust
        host  all all 0.0.0.0/0 md5
      '';
      settings = {
        listen_addresses = "*";
      };
      initialScript = pkgs.writeText "backend-initScript" ''
        CREATE ROLE patriot WITH LOGIN PASSWORD 'patriot' CREATEDB;
        CREATE DATABASE harmony;
        GRANT ALL PRIVILEGES ON DATABASE harmony TO patriot;
      '';
    };
  };
  virtualisation = {
    podman.enable = true;
    libvirtd.enable = false;
  };

  system.stateVersion = "20.09";
}
