{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = [pkgs.zoxide];
  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories =
    lib.singleton
    ".local/share/zoxide";
  programs.zsh.initExtra = ''
    eval "$(zoxide init zsh)"
  '';
}
