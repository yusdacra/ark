{inputs, ...}: {
  services.fail2ban.enable = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  users.users.root.openssh.authorizedKeys.keys = [
    (builtins.readFile "${inputs.self}/secrets/yusdacra.key.pub")
  ];
}
