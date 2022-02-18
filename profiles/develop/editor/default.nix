{
  pkgs,
  ...
}:
{
  imports = [./helix.nix];
  environment.systemPackages = with pkgs; [alejandra];
  environment.shellAliases = { nixf-all = "alejandra **/**.nix"; };
}
