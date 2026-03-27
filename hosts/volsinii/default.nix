{
  inputs,
  tlib,
  pkgs,
  ...
}:
{
  imports = [
    "${inputs.agenix}/modules/age.nix"
    "${inputs.home}/nixos"
    "${inputs.disko}/module.nix"
    ../../modules
    ../../modules/stylix-null.nix
    ../../users/root
    ../../users/dawn
    ../../users/claudey
    ./disk-config.nix
  ]
  ++ (tlib.importFolder (toString ./modules));

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  environment.systemPackages = [
    pkgs.curl
    pkgs.gitMinimal
  ];

  networking.firewall.enable = true;

  system.stateVersion = "25.05";
}
