{
  config,
  lib,
  tlib,
  pkgs,
  inputs,
  ...
}: {
  imports = with inputs;
  with nixos-hardware.nixosModules;
    [
      nixpkgs.nixosModules.notDetected
      nixos-persistence.nixosModule
      common-pc-ssd
      common-pc-laptop
      common-gpu-nvidia
      common-gpu-amd
      common-cpu-amd
      ../../users/root
      ../../users/patriot
    ]
    ++ (tlib.importFolder (toString ./modules));

  system.persistDir = "/persist";

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
  hardware.pulseaudio = {
    enable = false;
    support32Bit = true;
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
  };

  hardware = {
    bluetooth.enable = true;
    xpadneo.enable = true;
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

  # for tailscale
  networking.firewall.checkReversePath = "loose";
  services.tailscale.enable = true;

  services = {
    earlyoom.enable = true;
    gvfs.enable = true;
  };

  virtualisation = {
    waydroid.enable = false;
    podman.enable = false;
    docker.enable = true;
    libvirtd.enable = false;
  };

  system.stateVersion = "22.05";
}
