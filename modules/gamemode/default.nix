{
  pkgs,
  inputs,
  ...
}: let
  hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;

  startscript = pkgs.writeShellScript "gamemode-start" ''
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls /tmp/hypr | sort | tail -n 1)
    ${hyprland}/bin/hyprctl --batch 'keyword decoration:blur 0 ; keyword animations:enabled 0 ; keyword misc:no_vfr 1'
  '';

  endscript = pkgs.writeShellScript "gamemode-end" ''
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls /tmp/hypr | sort | tail -n 1)
    ${hyprland}/bin/hyprctl --batch 'keyword decoration:blur 1 ; keyword animations:enabled 1 ; keyword misc:no_vfr 0'
  '';
in {
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = 15;
      };
      custom = {
        start = "${startscript}";
        end = "${endscript}";
      };
    };
  };
}
