{
  config,
  lib,
  tlib,
  pkgs,
  inputs,
  ...
}:
{
  imports =
    with inputs;
    [
      "${inputs.disko}/module.nix"
      "${inputs.home}/nixos"
      "${inputs.nixos-hardware}/common/pc"
      "${inputs.nixos-hardware}/common/pc/ssd"
      "${inputs.nixos-hardware}/common/cpu/amd"
      "${inputs.nixos-hardware}/common/cpu/amd/pstate.nix"
      "${inputs.nixos-hardware}/common/cpu/amd/zenpower.nix"
      "${inputs.nixos-hardware}/common/gpu/amd"
      ../../users/root
      ../../users/mayer
      ../../modules/base
    ]
    ++ (tlib.importFolder (toString ./modules));

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
  };

  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  fonts = {
    enableDefaultPackages = true;
    packages = [ pkgs.dejavu_fonts ];
  };

  services.earlyoom.enable = true;

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.05";
}
