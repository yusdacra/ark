{
  pkgs,
  terra,
  inputs,
  ...
}:
{
  # imports = ["${inputs.moonlight}/nix/home-manager.nix"];

  home.packages = [
    (pkgs.discord.override {
      withMoonlight = true;
      inherit (terra) moonlight;
      withOpenASAR = true;
    })
  ];
}
