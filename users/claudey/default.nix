{lib, tlib, inputs, pkgs, ...}@nixosArgs:
let
  l = lib;
  nixosConfig = nixosArgs.config;
in
{
  users.users.claudey = {
    isNormalUser = true;
    createHome = true;
    home = "/home/claudey";
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      (builtins.readFile "${inputs.self}/secrets/yusdacra.key.pub")
    ];
    extraGroups = ["compsize"];
  };
  users.groups.compsize = {};

  environment.shells = with pkgs; [
    bashInteractive
    nushell
  ];

  nix.settings.allowed-users = ["claudey"];
  security.wrappers.compsize = {
    source = "${pkgs.compsize}/bin/compsize";
    capabilities = "cap_sys_admin=ep";
    owner = "root";
    group = "compsize";
    setuid = false;
    permissions = "u+rx,g+rx,o-rwx";
  };

  home-manager.users.claudey = {pkgs, ...}: {
      imports =
        let
          modulesToEnable = l.flatten [
            # dev stuff
            [
              "git"
            ]
          ];
        in
        l.flatten [
          (tlib.prefixStrings "${inputs.self}/users/modules/" modulesToEnable)
        ];

      home = {
        homeDirectory = nixosConfig.users.users.claudey.home;
        packages = with pkgs; [websocat claude-code cargo go gnumake sqlite postgresql (hiPrio clang) (lowPrio gcc) wild python3 nodejs];
      };
  };
}
