{
  pkgs,
  config,
  ...
}: {
  settings.terminal.name = "wezterm";
  home.packages = [pkgs.wezterm];
  xdg.enable = true;
  xdg.configFile = {
    "wezterm/wezterm.lua".text = ''
      local wezterm = require 'wezterm';
      local catppuccin = require("colors/catppuccin").setup {
      	-- whether or not to sync with the system's theme
      	sync = false,
      	-- the default/fallback flavour, when syncing is disabled
      	flavour = "mocha"
      }

      return {
        font = wezterm.font("${config.settings.font.name}"),
        font_size = ${builtins.toJSON config.settings.font.size},
        default_cursor_style = "BlinkingBar",
        enable_wayland = true,
        enable_tab_bar = false,
        colors = catppuccin,
        window_background_opacity = 0.85
      }
    '';
    "wezterm/colors/catppuccin.lua".source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/wezterm/65078e846c8751e9b4837a575deb0745f0c0512f/catppuccin.lua";
      sha256 = "sha256:0cm8kjjga9k1fzgb7nqjwd1jdjqjrkkqaxcavfxdkl3mw7qiy1ib";
    };
  };
}
