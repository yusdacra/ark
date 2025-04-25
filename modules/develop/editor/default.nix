{ pkgs, ... }:
{
  imports = [ ./helix.nix ];
  environment.systemPackages = with pkgs; [
    treefmt
    nixd
    nixfmt-rfc-style
  ];
}
