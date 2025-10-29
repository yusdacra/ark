{ pkgs, lib, ... }:
{
  home.shell.enableNushellIntegration = true;

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
    '';
    extraConfig = ''
      source ${./aliases.nu}
      $env.config.show_banner = false
    '';
  };
}
