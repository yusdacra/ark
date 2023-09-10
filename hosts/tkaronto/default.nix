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
      inputs.agenix.nixosModules.default
      nixpkgs.nixosModules.notDetected
      nixos-persistence.nixosModule
      common-pc-ssd
      common-pc-laptop
      common-gpu-nvidia
      common-gpu-amd
      common-cpu-amd
      common-cpu-amd-pstate
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
        value = "16777216";
      }
      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "16777216";
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
    enableDefaultPackages = true;
    fontconfig.enable = true;
    packages = [pkgs.dejavu_fonts];
  };

  environment = {
    sessionVariables.FLAKE = "/etc/nixos";
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

  networking.firewall.allowedUDPPorts = [4990 4995];
  # musikcube
  networking.firewall.allowedTCPPorts = [7905 7906] ++ [6695 6696 6697 6698 6699];

  # for tailscale
  networking.firewall.checkReversePath = "loose";
  services.tailscale.enable = true;

  services = {
    earlyoom.enable = true;
    gvfs.enable = true;
  };

  system.stateVersion = "22.05";
}
