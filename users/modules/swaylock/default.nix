{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.swaylock-effects];

  programs.swaylock.settings = {
    screenshot = true;
    ignore-empty-password = true;
    clock = true;
    effect-scale = "0.5";
    effect-greyscale = true;
    effect-blur = "20x3";
    font = config.settings.font.regular.name;
  };
}
