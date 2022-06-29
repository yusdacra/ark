{font, ...}: ''
  local wezterm = require 'wezterm';
  local catppuccin = require("colors/catppuccin").setup {
  	-- whether or not to sync with the system's theme
  	sync = true,
  	-- the flavours to switch between when syncing
  	-- available flavours: "latte" | "frappe" | "macchiato" | "mocha"
  	sync_flavours = {
  		light = "latte",
  		dark = "mocha"
  	},
  	-- the default/fallback flavour, when syncing is disabled
  	flavour = "mocha"
  }

  return {
    font = wezterm.font("${font.name}"),
    font_size = ${builtins.toJSON font.size},
    default_cursor_style = "BlinkingBar",
    enable_wayland = true,
    enable_tab_bar = false,
    colors = catppuccin
  }
''
