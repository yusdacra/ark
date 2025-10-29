{ lib, config, ... }:
{
  stylix.targets.tofi.enable = true;
  programs.tofi = {
    enable = true;
    settings = {
      outline-width = 0;
      border-width = 0;
      width = "48%";
      height = "20%";
      num-results = 7;
      font = lib.mkForce "${config.stylix.fonts.serif.package}/share/fonts/truetype/ComicRelief.ttf";
      hint-font = false;
      ascii-input = true;
      drun-launch = true;
    };
  };
}
