{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.discocss.hmModule];

  # programs.discocss = {
  #   enable = true;
  #   discord = inputs.webcord-flake.packages.${pkgs.system}.webcord;
  #   discordAlias = true;
  #   css = builtins.readFile ./theme.css;
  # };

  home.packages = [inputs.webcord-flake.packages.${pkgs.system}.webcord];
  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories = [
    ".config/WebCord"
  ];
}
