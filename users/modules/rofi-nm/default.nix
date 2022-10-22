{
  config,
  pkgs,
  lib,
  ...
}: let
  rofi-nm = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/P3rf/rofi-network-manager/1daa69406c9b6539a4744eafb0d5bb8afdc80e9b/rofi-network-manager.sh";
    hash = "sha256:1nlnjmk5b743j5826z2nzfvjwk0fmbf7gk38darby93kdr3nv5zx";
  };
  package = pkgs.writeShellScriptBin "rofi-nm" ''
    ${config.home.homeDirectory}/.config/rofi-nm/rofi-nm.sh
  '';
in {
  options = {
    programs.rofi-nm.package = lib.mkOption {
      type = lib.types.package;
    };
  };
  config = {
    programs.rofi-nm.package = package;

    home.packages = [package];

    xdg.configFile = {
      "rofi-nm/rofi-nm.sh" = {
        source = pkgs.runCommandLocal "rofi-nm" {} ''
          cp --no-preserve=mode,ownership ${rofi-nm} rofi-nm.sh
          substituteInPlace rofi-nm.sh \
            --replace "#!/bin/bash" "#!${pkgs.stdenv.shell}" \
            --replace "grep" "${pkgs.gnugrep}/bin/grep"
          mv rofi-nm.sh $out
        '';
        executable = true;
      };
      "rofi-nm/rofi-network-manager.conf".text = ''
        LOCATION=3
        WIDTH_FIX_MAIN=10
        WIDTH_FIX_STATUS=10
      '';
      "rofi-nm/rofi-network-manager.rasi".text = ''
        configuration {
          	show-icons:		false;
          	sidebar-mode: 	false;
          	hover-select: true;
          	me-select-entry: "";
          	me-accept-entry: [MousePrimary];
        }

        * {
            font: "${config.settings.font.regular.fullName}";
        }

        @theme "catppuccin"

        element-text, element-icon , mode-switcher {
            background-color: inherit;
            text-color:       inherit;
        }

        window {
            height: 40%;
            width: 40%;
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
            placeholder: "";
            padding: 6px;
            margin: 20px 0px 0px 10px;
            text-color: @fg-col;
            background-color: @bg-col;
        }

        listview {
            border: 0px 0px 0px;
            padding: 6px 0px 0px;
            margin: 10px 0px 0px 20px;
            columns: 1;
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
  };
}
