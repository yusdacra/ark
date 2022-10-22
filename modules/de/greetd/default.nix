{pkgs, ...}: {
  services.greetd = {
    enable = true;
    settings = {
      terminal.vt = 1;
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --issue --time --cmd 'apply-hm-env Hyprland'";
        user = "greeter";
      };
    };
  };
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };
}
