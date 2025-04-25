{ lib, ... }:
{
  imports = [ ./default.nix ];

  config = {
    system.persistDir = "null";
  };

  options = {
    home.persistence = lib.mkOption {
      type = lib.raw;
    };
    environment.persistence = lib.mkOption {
      type = lib.raw;
    };
  };
}
