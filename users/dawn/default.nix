{lib, tlib, inputs, pkgs, ...}@nixosArgs:
let
  l = lib;
  nixosConfig = nixosArgs.config;
in
{
  users.users.dawn = {
    isNormalUser = true;
    createHome = true;
    home = "/home/dawn";
    extraGroups = ["wheel"];
    shell = pkgs.bashInteractive;
    hashedPassword = "$y$j9T$TxLlqj0RWsBtIrEhOTyqh1$mfvSCn5j7VAUymWe2/qUTB7.JdwXbqF5qWqUjqQCMu3";
    openssh.authorizedKeys.keys = [
      (builtins.readFile "${inputs.self}/secrets/yusdacra.key.pub")
    ];
  };

  environment.shells = with pkgs; [
    bashInteractive
    nushell
  ];

  home-manager.users.dawn = {pkgs, ...}: {
      imports =
        let
          modulesToEnable = l.flatten [
            [
              "zoxide"
              "direnv"
              "nushell"
            ]
            # dev stuff
            [
              "zed"
              "helix"
              "git"
              "ssh"
            ]
          ];
        in
        l.flatten [
          (tlib.prefixStrings "${inputs.self}/users/modules/" modulesToEnable)
        ];

      home = {
        homeDirectory = nixosConfig.users.users.dawn.home;
        packages = with pkgs; [omnisharp-roslyn rustup gcc gnumake cmake dotnet-sdk_8];
      };
  };
}
