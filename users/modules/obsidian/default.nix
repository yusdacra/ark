{pkgs, config, lib, ...}: {
  home.packages = [pkgs.obsidian];
  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories = [".config/obsidian"];
}
