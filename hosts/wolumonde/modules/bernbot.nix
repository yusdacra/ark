{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  bernbotPkg = inputs.bernbot.packages.${pkgs.system}.bernbot-release;
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
        EnvironmentFile = config.age.secrets.bernbotToken.path;
      }
    ];
  };
  users.users.bernbot = {
    isSystemUser = true;
    group = "bernbot";
  };
  users.groups.bernbot = {};
}
