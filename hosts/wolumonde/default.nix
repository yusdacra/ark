{
  inputs,
  tlib,
  pkgs,
  ...
}:
{
  imports = with inputs; [
    ../../modules
    ../../modules/stylix-null.nix
    ../../locale
    ../../users/root
    "${home}/nixos"
    "${agenix}/modules/age.nix"
    "${ncr}/firewall"
    "${ncr}/firewall/hetzner"
  ]
  ++ (tlib.importFolder (toString ./modules));

  environment.systemPackages = with pkgs; [
    magic-wormhole-rs
    systemctl-tui
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  # firewall stuffs
  networking.firewall.enable = true;
  providers.hetzner.firewall = {
    enable = true;
    id = 476406;
  };

  system.stateVersion = "22.05";
}
