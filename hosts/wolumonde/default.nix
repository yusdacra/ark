{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.cleanTmpDir = true;
  zramSwap.enable = true;

  # ssh config
  services.fail2ban.enable = true;
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };
  users.users.root.openssh.authorizedKeys.keys = [
    (builtins.readFile "${inputs.self}/secrets/ssh-key.pub")
  ];

  # nginx
  services.nginx = {
    enable = true;
    virtualHosts."gaze.systems" = {
      enableACME = true;
      forceSSL = true;
      root = "${inputs.blog.packages.${pkgs.system}.website}";
    };
  };
  security.acme = {
    acceptTerms = true;
    certs = {
      "gaze.systems".email = "y.bera003.06@pm.me";
    };
  };

  # firewall stuffs
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPortRanges = [ ];
  };

  # nixinate for deployment
  _module.args.nixinate = {
    host = builtins.readFile "${inputs.self}/secrets/wolumonde-ip";
    sshUser = "root";
    buildOn = "local"; # valid args are "local" or "remote"
    substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
    hermetic = true;
  };

  system.stateVersion = "22.05";
}
