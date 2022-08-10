{inputs, ...}: {
  services.fail2ban.enable = true;
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };
  users.users.root.openssh.authorizedKeys.keys = [
    (builtins.readFile "${inputs.self}/secrets/ssh-key.pub")
  ];
}
