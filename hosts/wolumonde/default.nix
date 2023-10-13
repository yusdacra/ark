{
  inputs,
  tlib,
  ...
}: {
  imports =
    [
      inputs.agenix.nixosModules.default
    ]
    ++ (tlib.importFolder (toString ./modules));

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  # firewall stuffs
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443 5005];
    allowedUDPPortRanges = [];
  };

  system.stateVersion = "22.05";
}
