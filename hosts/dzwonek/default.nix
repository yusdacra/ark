{
  inputs,
  tlib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    "${inputs.agenix}/modules/age.nix"
    "${inputs.home}/nixos"
    "${inputs.disko}/module.nix"
    ../../modules
    ../../users/root
    ./disk-config.nix
  ]
  ++ (tlib.importFolder (toString ./modules));


  environment.systemPackages = [
    pkgs.curl
    pkgs.gitMinimal
  ];

  networking.firewall.enable = true;

  system.stateVersion = "25.05";
}
