{
  inputs,
  pkgs,
  lib,
  ...
}: let
  bernbotPkg = inputs.bernbot.packages.${pkgs.system}.bernbot;
in {
  systemd.services.bernbot = {
    description = "bernbot";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = lib.mkMerge [
      {
        User = "bernbot";
        ExecStart = "${bernbotPkg}/bin/bernbot";
        Restart = "on-failure";
        RestartSec = 5;
        WorkingDirectory = "/var/lib/bernbot";
        EnvironmentFile = "${inputs.self}/secrets/bernbot_token";
      }
    ];
  };
  users.users.bernbot = {
    isSystemUser = true;
    group = "bernbot";
  };
  users.groups.bernbot = {};
}
