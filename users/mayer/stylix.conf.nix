{
  config,
  pkgs,
  ...
}:
{
  stylix.enable = true;
  stylix.autoEnable = false;

  stylix.targets = {
    console.enable = true;
    fontconfig.enable = true;
    font-packages.enable = true;
    qt.enable = true;
    gnome.enable = true;
    gtk.enable = true;
  };

  stylix.image = ./wallpaper.png;
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.override = {
    base00 = "#000000";
    base01 = "#11111b";
    base0D = "#cba6f7";
    base0E = "#89b4fa";
  };

  stylix.cursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
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

  stylix.opacity = {
    terminal = 0.85;
    applications = 0.9;
    desktop = 0.9;
    popups = 0.9;
  };

  stylix.icons = {
    enable = true;
    dark = "Yaru-dark";
    light = "Yaru";
    package = pkgs.yaru-theme;
  };
}
