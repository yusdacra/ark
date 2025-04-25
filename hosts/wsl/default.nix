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
    ../../users/root
    ../../users/firewatch
    inputs.nixos-wsl.nixosModules.wsl
    inputs.agenix.nixosModules.default
  ] ++ (tlib.importFolder (toString ./modules));

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
