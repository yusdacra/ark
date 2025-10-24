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
          "tailscale"
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
      "${inputs.agenix}/modules/age-home.nix"
      ../../modules/persist/null.nix
      (tlib.prefixStrings "${inputs.self}/users/modules/" modulesToEnable)
      ./nsid-tracker.nix
    ];

  systemd.user.settings.Manager.DefaultEnvironment = {
    PATH = "${pkgs.coreutils-full}/bin:$PATH";
  };

  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  home = {
    homeDirectory = "/home/dusk";
    username = "dusk";
    stateVersion = "25.11";
    # shell
    shell.enableShellIntegration = true;
    shellAliases = {
      ctl = "systemctl --user";
      jtl = "journalctl --user";
      g = "git";
      e = "hx";
    };
    sessionVariables = {
      EDITOR = "hx";
    };
  };

  age.secrets.tailscaleAuthKey = {
    file = ../../secrets/develMobiTailscaleAuthKey.age;
    mode = "600";
  };
  services.tailscale = {
    enable = true;
    controlServer = "https://vpn.gaze.systems";
    authKeyFile = config.age.secrets.tailscaleAuthKey.path;
    extraUpFlags = [ "--advertise-exit-node=true" "--hostname=dusk-devel-mobi" ];
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
