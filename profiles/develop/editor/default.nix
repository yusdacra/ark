{ pkgs, ... }: {
  imports = [ ./kakoune.nix ];

  environment.systemPackages = with pkgs; [ nixfmt ];
  environment.shellAliases = { nixf-all = "nixfmt **/**.nix"; };
}
