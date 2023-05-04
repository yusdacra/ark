{
  inputs,
  tlib,
  ...
}: { 
  imports = [
    inputs.agenix.nixosModules.default
  ] ++ (tlib.importFolder (toString ./modules));

  boot.cleanTmpDir = true;
  zramSwap.enable = true;

  # firewall stuffs
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443];
    allowedUDPPortRanges = [];
  };

  system.stateVersion = "22.05";
}
