{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.ripcord];
  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories = [
    ".local/share/Ripcord"
  ];
}
