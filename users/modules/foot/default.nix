{
  lib,
  pkgs,
  ...
}:
{
  settings.terminal.name = "foot";
  settings.terminal.binary = "${pkgs.foot}/bin/foot";
  programs.foot = {
    enable = true;
    package = pkgs.foot;
    server.enable = false;
    settings = {
      main = {
        login-shell = "yes";
        dpi-aware = lib.mkForce "yes";
        font = "Comic Mono:size=12";
      };
      csd = {
        preferred = "client";
        size = 0;
      };
      mouse.hide-when-typing = "yes";
      scrollback.lines = 100000;
      bell.system = "no";
    };
  };
}
