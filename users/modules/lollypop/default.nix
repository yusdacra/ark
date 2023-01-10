{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.lollypop];
  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories = [".local/share/lollypop"];
}
