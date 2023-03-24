{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [inputs.stylix.nixosModules.stylix];

  stylix.image = ./wallpaper.png;
  stylix.polarity = "dark";

  stylix.fonts = {
    serif = {
      name = "Comic Relief";
      package = pkgs.comic-relief;
    };
    sansSerif = config.stylix.fonts.serif;
    monospace = {
      name = "Comic Mono";
      package = pkgs.comic-mono;
    };
  };

  stylix.fonts.sizes = {
    popups = 13;
    terminal = 13;
  };
}
