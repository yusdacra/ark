{pkgs, ...}: {
  programs.swaylock = {
    package = pkgs.swaylock-effects;
    settings = {
      screenshot = true;
      ignore-empty-password = true;
      clock = true;
      effect-scale = "0.5";
      effect-greyscale = true;
      effect-blur = "20x3";
    };
  };
}
