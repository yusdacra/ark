{ pkgs, ... }:
{
  stylix.targets.zed.enable = true;
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" "deno" "toml" "svelte" ];
    extraPackages = with pkgs; [ nixd nil ];
    installRemoteServer = true;
  };
}
