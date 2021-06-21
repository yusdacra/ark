{ pkgs, ... }: {
  imports = [ ./helix.nix ];

  environment.systemPackages = with pkgs; [ nixpkgs-fmt ];
  environment.shellAliases = { nixf-all = "nixpkgs-fmt **/**.nix"; };
}
