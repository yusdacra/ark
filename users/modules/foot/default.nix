{
  lib,
  pkgs,
  ...
}: {
  settings.terminal.name = "foot";
  settings.terminal.binary = "${pkgs.foot}/bin/foot";
  programs.foot = {
    enable = true;
    package = pkgs.foot;
    server.enable = false;
    settings.main.dpi-aware = lib.mkForce "yes";
  };
}
