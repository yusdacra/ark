{ pkgs, lib, ... }:
{
  home.shell.enableNushellIntegration = true;

  programs.carapace.enable = true;
  programs.nushell = {
    enable = true;
    extraEnv = ''
      source-env ${./prompt.nu}
    '';
    extraConfig = ''
      source ${./aliases.nu}
    '';
  };
}
