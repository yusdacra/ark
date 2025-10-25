{
  config,
  lib,
  tlib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../../modules
    ../../locale
    "${inputs.home}/nixos"
    ../../users/root
    ../../users/firewatch
    "${inputs.nixos-wsl}/modules"
    "${inputs.agenix}/modules/age.nix"
  ]
  ++ (tlib.importFolder (toString ./modules));

  wsl.enable = true;
  wsl.defaultUser = "firewatch";

  nix.settings.max-jobs = lib.mkForce 10;

  networking.hostName = "wsl";

  environment.systemPackages = [ pkgs.wget ];
  environment.sessionVariables = {
    FLAKE = "/home/firewatch/ark";
  };

  # for tailscale
  networking.firewall.checkReversePath = "loose";
  services.tailscale.enable = true;

  services.earlyoom.enable = true;

  system.stateVersion = "23.11";
}
