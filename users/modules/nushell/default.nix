{ pkgs, lib, ... }:
{
  home.shell.enableNushellIntegration = true;

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
      source-env ${./prompt.nu}
      if (which node | length) > 0 {
        use std/util "path add"
        mkdir ~/.npm-global
        npm config set prefix '~/.npm-global'
        path add '~/.npm-global/bin'
      }
    '';
    extraConfig = ''
      source ${./aliases.nu}
      $env.config.show_banner = false
    '';
  };
}
