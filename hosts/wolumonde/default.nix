{
  inputs,
  tlib,
  pkgs,
  ...
}: {
  imports =
    [
      inputs.agenix.nixosModules.default
      inputs.nixtopo.nixosModules.default
    ]
    ++ (tlib.importFolder (toString ./modules));

  environment.systemPackages = [pkgs.magic-wormhole-rs];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  # firewall stuffs
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443 5005];
    allowedUDPPortRanges = [];
  };

  virtualisation.docker.enable = true;

  system.stateVersion = "22.05";
}
