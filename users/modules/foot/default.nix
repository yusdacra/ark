{
  config,
  inputs,
  ...
}: {
  settings.terminal.name = "foot";
  programs.foot = {
    enable = true;
    server.enable = false;
    settings = {
      main = {
        font = "${config.settings.font.name}:size=${toString config.settings.font.size}";
        dpi-aware = "yes";
      };
      colors = import "${inputs.self}/colors";
    };
  };
}
