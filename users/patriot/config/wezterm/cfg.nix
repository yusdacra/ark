{font, ...}: ''
  local wezterm = require 'wezterm';

  return {
    font = wezterm.font("${font.name}"),
    font_size = ${builtins.toJSON font.size},
    color_scheme = "mytheme"
  }
''
