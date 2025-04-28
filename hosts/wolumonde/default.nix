{
  inputs,
  tlib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.default
    # inputs.nixtopo.nixosModules.default
  ] ++ (tlib.importFolder (toString ./modules));

  environment.systemPackages = with pkgs; [
    magic-wormhole-rs
    systemctl-tui
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  # firewall stuffs
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
      5005
    ];
    allowedUDPPortRanges = [ ];
  };

  virtualisation.docker.enable = false;

  system.stateVersion = "22.05";
}
