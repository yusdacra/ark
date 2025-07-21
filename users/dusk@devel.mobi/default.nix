{
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
      ../../modules/persist/null.nix
      (tlib.prefixStrings "${inputs.self}/users/modules/" modulesToEnable)
    ];

  home = {
    homeDirectory = "/home/dusk";
    username = "dusk";
    stateVersion = "25.11";
    # file.".ssh/authorized_keys".text = ''
    #   ${signKeyText}
    # '';
  };

  programs = {
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

  services.podman = {
    enable = true;
  };
}
