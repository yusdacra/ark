username: {pkgs, ...}: {
  services.psd.enable = true;

  security.sudo.extraRules = [
    {
      users = [username];
      commands = [
        {
          command = "${pkgs.profile-sync-daemon}/bin/psd-overlay-helper";
          options = ["SETENV" "NOPASSWD"];
        }
      ];
    }
  ];

  home-manager.users.${username} = {
    xdg.enable = true;
    xdg.configFile."psd/psd.conf".text = ''
      USE_OVERLAYFS="no"
      BROWSERS=(chromium)
      USE_BACKUPS="no"
    '';
  };
}
