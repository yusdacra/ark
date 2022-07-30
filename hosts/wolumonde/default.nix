{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.cleanTmpDir = true;
  zramSwap.enable = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    (builtins.readFile "${inputs.self}/secrets/ssh-key.pub")
  ];
}