{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [wlopm swayidle];
  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "swaylock";
      }
      {
        event = "lock";
        command = "swaylock";
      }
    ];
    timeouts = [
      {
        timeout = 120;
        command = "wlopm --off \*";
        resumeCommand = "wlopm --on \*";
      }
      {
        timeout = 300;
        command = "loginctl lock-session";
      }
    ];
  };
  systemd.user.services.swayidle.Install.WantedBy = lib.mkForce ["hyprland-session.target"];
}
