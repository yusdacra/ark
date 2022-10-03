{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  theme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/discord/c162aee9d71a06908abf285f9a5239c6bea8b5e9/themes/mocha.theme.css";
    hash = "sha256-dPKW+Mru+KvivvobwbOgj2g8mSiSspdVOXrxbXCel8M=";
  };
in {
  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories = [
    ".config/WebCord"
  ];
  home.packages = let
    pkg = inputs.webcord.packages.${pkgs.system}.webcord.override {
      flags = "--add-css-theme=${theme}";
    };
  in [pkg];
}
