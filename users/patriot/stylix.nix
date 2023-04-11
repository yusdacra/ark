{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix.image = ./wallpaper.png;
  stylix.polarity = "dark";
  stylix.base16Scheme = {
    "base00" = "04080e";
    "base01" = "36393e";
    "base02" = "686b6e";
    "base03" = "9b9c9f";
    "base04" = "cdcecf";
    "base05" = "ffffff";
    "base06" = "1d2126";
    "base07" = "e6e6e7";
    "base08" = "cf0466"; # splatoon 2 pink
    "base09" = "2851f6"; # splatoon 1 blue
    "base0A" = "6844e6"; # splatoon 3 purple
    "base0B" = "17a80d"; # splatoon 2 green
    "base0C" = "fea972"; # splatoon 3 fuzzy orange color
    "base0D" = "fa5a00"; # splatoon 1 orange
    "base0E" = "fffe27"; # splatoon 3 yellow
    "base0F" = "bdbebc";
  };

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
