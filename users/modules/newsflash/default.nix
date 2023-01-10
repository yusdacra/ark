{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.newsflash];
  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories = [
    ".local/share/news-flash"
    ".config/news-flash"
  ];
}
