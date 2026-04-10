{
  tlib,
  pkgs,
  inputs,
  ...
}:
{
  imports =
    with inputs;
    [
      "${facter}/modules/nixos/facter.nix"
      "${disko}/module.nix"
      "${home}/nixos"
      "${nixos-hardware}/common/pc"
      "${nixos-hardware}/common/pc/ssd"
      "${nixos-hardware}/common/cpu/amd"
      "${nixos-hardware}/common/cpu/amd/pstate.nix"
      "${nixos-hardware}/common/cpu/amd/zenpower.nix"
      "${nixos-hardware}/common/gpu/amd"
      ../../users/root
      ../../users/mayer
      ../../modules
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
      noto-fonts-color-emoji
      font-awesome
      source-han-serif
      source-han-sans
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
    # fontconfig.hinting.style = "full";
    # fontconfig.subpixel.rgba = "rgb";
  };

  services.earlyoom.enable = true;

  hardware.enableRedistributableFirmware = true;

  virtualisation.podman.enable = true;

  system.stateVersion = "25.05";
}
