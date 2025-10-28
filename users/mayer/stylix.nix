{
  inputs,
  config,
  pkgs,
  terra,
  lib,
  ...
}:
{
  imports = [ (import inputs.stylix).homeModules.stylix ];

  stylix.image = ./wallpaper.png;
  stylix.polarity = "dark";
  stylix.base16Scheme =
    let
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
    in
    {
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
      package = terra.comic-mono;
    };
  };

  stylix.fonts.sizes = {
    popups = 13;
    terminal = 13;
  };
}
