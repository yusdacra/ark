{inputs, ...}: {
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

  _module.args.nixinate = {
    host = builtins.readFile "${inputs.self}/secrets/wolumonde-ip";
    sshUser = "root";
    buildOn = "local"; # valid args are "local" or "remote"
    substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
    hermetic = true;
  };
}
