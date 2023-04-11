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
    "base00" = "191a16";
    "base01" = "20211c";
    "base02" = "24251f"; # splatoon 3 dark background
    "base03" = "50514c";
    "base04" = "7c7c79";
    "base05" = "a7a8a5";
    "base06" = "d3d3d2";
    "base07" = "ffffff";
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
