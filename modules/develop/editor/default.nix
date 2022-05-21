{pkgs, ...}: {
  imports = [./helix.nix];
  environment.systemPackages = with pkgs; [alejandra treefmt];
  environment.shellAliases = {nixf-all = "alejandra **/**.nix";};
}
