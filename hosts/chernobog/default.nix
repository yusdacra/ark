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
      "${inputs.facter}/modules/nixos/facter.nix"
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
      ../../locale/default.nix
    ]
    ++ (tlib.importFolder (toString ./modules));

  facter.reportPath = ./facter.json;

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

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-emoji
      font-awesome
      source-han-serif
      source-han-sans
      source-han-sans-japanese
      source-han-serif-japanese
      comic-mono
      comic-relief
    ];
    fontconfig.defaultFonts = {
      serif = [
        "Comic Relief"
        "Noto Serif"
        "Source Han Serif"
      ];
      sansSerif = [
        "Comic Relief"
        "Noto Sans"
        "Source Han Sans"
      ];
      monospace = [ "Comic Mono" ];
    };
  };

  services.earlyoom.enable = true;

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.05";
}
