{
  inputs,
  tlib,
  pkgs,
  ...
}:
{
  imports = with inputs; [
    "${facter}/modules/nixos/facter.nix"
    "${agenix}/modules/age.nix"
    "${home}/nixos"
    "${disko}/module.nix"
    ../../modules
    ../../modules/stylix-null.nix
    ../../users/root
    ./disk-config.nix
  ]
  ++ (tlib.importFolder (toString ./modules));
  facter.reportPath = ./facter.json;

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  environment.systemPackages = [
    pkgs.curl
    pkgs.gitMinimal
  ];

  networking.firewall.enable = true;

  system.stateVersion = "25.11";
}
