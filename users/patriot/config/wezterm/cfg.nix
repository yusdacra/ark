{font, ...}: ''
  local wezterm = require 'wezterm';

  return {
    font = wezterm.font("${font.name}"),
    font_size = ${builtins.toJSON font.size},
    color_scheme = "Grape",
    default_cursor_style = "BlinkingBar",
    enable_wayland = true,
    enable_tab_bar = false
  }
''
