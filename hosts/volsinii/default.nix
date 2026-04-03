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

  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nofile"; value = "1048576"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; }
  ];

  system.stateVersion = "25.05";
}
