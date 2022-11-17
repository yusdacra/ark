{
  config,
  pkgs,
  ...
}: {
  services.spotifyd = {
    enable = true;
    settings = {
      device_name = "nix";
    };
  };
  home.packages = [pkgs.spotify-tui];
  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories = [
    ".config/spotify-tui"
  ];
}
