{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  personal = import "${inputs.self}/personal.nix";
  email = personal.emails.short;
in {
  imports = [
    ./hardware-configuration.nix
    ./bernbot.nix
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
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    virtualHosts."gaze.systems" = {
      enableACME = true;
      forceSSL = true;
      root = "${inputs.blog.packages.${pkgs.system}.website}";
      locations."/".extraConfig = ''
        add_header cache-control max-age=1800;
      '';
    };
    virtualHosts."git.gaze.systems" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:3001";
    };
  };
  security.acme = {
    acceptTerms = true;
    certs = {
      "gaze.systems".email = email;
      "git.gaze.systems".email = email;
    };
  };

  # gitea
  services.gitea = {
    enable = true;
    cookieSecure = true;
    disableRegistration = true;
    domain = "git.gaze.systems";
    rootUrl = "https://git.gaze.systems/";
    httpPort = 3001;
  };

  # firewall stuffs
  networking.firewall = {
    enable = true;
    allowedTCPPorts = lib.flatten [
      [22 80 443]
      (
        lib.optional
        config.services.gitea.enable
        config.services.gitea.httpPort
      )
    ];
    allowedUDPPortRanges = [];
  };

  # nixinate for deployment
  _module.args.nixinate = {
    host = "gaze.systems";
    sshUser = "root";
    buildOn = "local"; # valid args are "local" or "remote"
    substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
    hermetic = true;
  };

  system.stateVersion = "22.05";
}
