{
  config,
  pkgs,
  lib,
  tlib,
  inputs,
  ...
}:
let
  l = lib // builtins;

  signKeyText = builtins.readFile ../../secrets/yusdacra.key.pub;
  personal = import ../../personal.nix;
  name = personal.name;
  email = personal.emails.primary;
in
{
  imports =
    let
      modulesToEnable = l.flatten [
        [
          "zoxide"
          "fzf"
          "direnv"
          "nushell"
          "netbird"
        ]
        # dev stuff
        [
          "helix"
          "git"
          "ssh"
        ]
      ];
    in
    l.flatten [
      inputs.agenix.homeManagerModules.default
      ../../modules/persist/null.nix
      (tlib.prefixStrings "${inputs.self}/users/modules/" modulesToEnable)
    ];

  age.identityPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
  home = {
    homeDirectory = "/home/dusk";
    username = "dusk";
    stateVersion = "25.11";
    # shell
    shell.enableShellIntegration = true;
    shellAliases = {
      ctl = "systemctl --user";
      jtl = "journalctl --user";
      jtlu = "journalctl --user --unit";
    };
  };

  age.secrets.netbirdClientKey = {
    file = ../../secrets/develMobiNetbirdClientKey.age;
    mode = "600";
  };
  services.netbird = {
    enable = true;
    managementUrl = "https://bird.gaze.systems";
    setupKeyFile = config.age.secrets.netbirdClientKey.path;
  };

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
    };
    tealdeer.enable = true;
    git = {
      userName = name;
      userEmail = email;
      extraConfig = {
        gpg.format = "ssh";
        commit.gpgsign = true;
        user.signingkey = signKeyText;
      };
    };
  };
}
