{
  pkgs,
  lib,
  tlib,
  config,
  ...
}@globalAttrs:
let
  l = lib // builtins;

  nixosConfig = globalAttrs.config;

  signKeyText = builtins.readFile ../../secrets/yusdacra.key.pub;
in
{
  users.users.firewatch = {
    isNormalUser = true;
    createHome = true;
    home = "/home/firewatch";
    extraGroups = l.flatten [
      "wheel"
      "adbusers"
      "nix-build-key-access"
      (l.optional nixosConfig.virtualisation.docker.enable "docker")
    ];
    shell = pkgs.zsh;
    hashedPassword = "$6$spzqhAyJfhHy$iHgLBlhjGn1l8PnbjJdWTn1GPvcjMqYNKUzdCe/7IrX6sHNgETSr/Nfpdmq9FCXLhrAfwHOd/q/8SvfeIeNX4/";
  };
  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];
  programs = {
    # cuz nixos complains
    zsh.enable = true;
  };
  home-manager.users.firewatch =
    {
      config,
      pkgs,
      inputs,
      secrets,
      ...
    }:
    let
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
              "zsh"
              "fzf"
              "starship"
              "direnv"
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

      settings.enable = false;

      home = {
        homeDirectory = nixosConfig.users.users.firewatch.home;
        packages = with pkgs; [
          # Programs
          nix-output-monitor
          inputs.nh.packages.${pkgs.system}.default
        ];
        file.".ssh/authorized_keys".text = ''
          ${signKeyText}
        '';
      };

      programs = {
        command-not-found.enable = nixosConfig.programs.command-not-found.enable;
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
    };
}
