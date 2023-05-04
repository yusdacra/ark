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
  # stylix.base16Scheme = {
  #   "base00" = "04080e";
  #   "base01" = "36393e";
  #   "base02" = "686b6e";
  #   "base03" = "9b9c9f";
  #   "base04" = "cdcecf";
  #   "base05" = "ffffff";
  #   "base06" = "1d2126";
  #   "base07" = "e6e6e7";
  #   "base08" = "cf0466"; # splatoon 2 pink
  #   "base09" = "2851f6"; # splatoon 1 blue
  #   "base0A" = "6844e6"; # splatoon 3 purple
  #   "base0B" = "17a80d"; # splatoon 2 green
  #   "base0C" = "fea972"; # splatoon 3 fuzzy orange color
  #   "base0D" = "fa5a00"; # splatoon 1 orange
  #   "base0E" = "fffe27"; # splatoon 3 yellow
  #   "base0F" = "bdbebc";
  # };
  stylix.base16Scheme = let
    night = "#2b292d";
    ash = "#383539";
    umber = "#4d424b";
    bark = "#6F5D63";
    mist = "#D1D1E0";
    sage = "#B1B695";
    blush = "#fecdb2";
    coral = "#ffa07a";
    rose = "#F6B6C9";
    ember = "#e06b75";
    honey = "#F5D76E";
  in {
    base00 = night;
    base01 = ash;
    base02 = umber;
    base03 = bark;
    base04 = blush;
    base05 = mist;
    base06 = mist;
    base07 = bark;
    base08 = ember;
    base09 = honey;
    base0A = rose;
    base0B = sage;
    base0C = bark;
    base0D = coral;
    base0E = blush;
    base0F = umber;
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
