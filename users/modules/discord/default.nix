{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.discocss.hmModule];

  programs.discocss = {
    enable = true;
    discord = inputs.fufexan.packages.${pkgs.system}.discord-electron-openasar;
    discordAlias = true;
    css = builtins.readFile ./theme.css;
  };

  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories = [
    ".config/discord"
  ];
}
