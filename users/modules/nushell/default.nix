{ pkgs, lib, ... }:
{
  home.shell.enableNushellIntegration = true;

  xdg.configFile = {
    "nushell/prompt.nu".text = builtins.readFile ./prompt.nu;
    "nushell/aliases.nu".text = builtins.readFile ./aliases.nu;
  };

  stylix.targets.nushell.enable = true;
  programs.carapace.enable = true;
  programs.nushell = {
    enable = true;
    shellAliases = lib.mapAttrs (_: lib.mkForce) {
      myip = "echo";
      l = "ls";
      ls = "ls";
      ll = "ls -l";
      la = "ls -a";
    };
    extraEnv = ''
      source-env ~/.config/nushell/prompt.nu
      if (which node | length) > 0 {
        use std/util "path add"
        mkdir ~/.npm-global
        npm config set prefix '~/.npm-global'
        path add '~/.npm-global/bin'
      }
    '';
    extraConfig = ''
      source ~/.config/nushell/aliases.nu
      $env.config.show_banner = false
    '';
  };
}
