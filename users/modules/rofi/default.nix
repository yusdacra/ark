{
  pkgs,
  config,
  ...
}: {
  home.packages = [pkgs.rofi-wayland];
  xdg.enable = true;
  xdg.dataFile = {
    "rofi/themes/catppuccin.rasi".source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/rofi/c7c242d6bfd4cabdc9a220cff71e3b0766811fbe/.local/share/rofi/themes/catppuccin.rasi";
      sha256 = "sha256:17jssby0llsnabzfz3lp4wcc9vdzfz77i5wjcclfcyyvpswc53nx";
    };
  };
  xdg.configFile = {
    "rofi/config.rasi".text = ''
      configuration{
          modi: "drun";
          lines: 5;
          font: "${config.fonts.settings.name} ${toString config.fonts.settings.size}";
          show-icons: true;
          terminal: "st";
          drun-display-format: "{icon} {name}";
          location: 0;
          disable-history: false;
          hide-scrollbar: true;
          display-drun: "   Apps ";
          display-run: "   Run ";
          display-window: " 﩯  Window";
          display-Network: " 󰤨  Network";
          sidebar-mode: true;
      }

      @theme "catppuccin"

      element-text, element-icon , mode-switcher {
          background-color: inherit;
          text-color:       inherit;
      }

      window {
          height: 360px;
          border: 3px;
          border-color: @border-col;
          background-color: @bg-col;
      }

      mainbox {
          background-color: @bg-col;
      }

      inputbar {
          children: [prompt,entry];
          background-color: @bg-col;
          border-radius: 5px;
          padding: 2px;
      }

      prompt {
          background-color: @blue;
          padding: 6px;
          text-color: @bg-col;
          border-radius: 3px;
          margin: 20px 0px 0px 20px;
      }

      textbox-prompt-colon {
          expand: false;
          str: ":";
      }

      entry {
          padding: 6px;
          margin: 20px 0px 0px 10px;
          text-color: @fg-col;
          background-color: @bg-col;
      }

      listview {
          border: 0px 0px 0px;
          padding: 6px 0px 0px;
          margin: 10px 0px 0px 20px;
          columns: 2;
          background-color: @bg-col;
      }

      element {
          padding: 5px;
          background-color: @bg-col;
          text-color: @fg-col  ;
      }

      element-icon {
          size: 25px;
      }

      element selected {
          background-color:  @selected-col ;
          text-color: @fg-col2  ;
      }

      mode-switcher {
          spacing: 0;
        }

      button {
          padding: 10px;
          background-color: @bg-col-light;
          text-color: @grey;
          vertical-align: 0.5;
          horizontal-align: 0.5;
      }

      button selected {
        background-color: @bg-col;
        text-color: @blue;
      }
    '';
  };
}
