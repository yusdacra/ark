{ pkgs, lib, config, ... }:
{
  stylix.targets.tofi.enable = true;
  programs.tofi = {
    enable = true;
    package = pkgs.tofi.overrideAttrs (old: {
      patches = [(pkgs.fetchpatch2 {
        url = "https://patch-diff.githubusercontent.com/raw/philj56/tofi/pull/189.patch";
        hash = "sha256-qsXRyNE9x1sSDrCq/LTQY/DTEMwYAJB3U0/dPXX/jw4=";
      })];
    });
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
