{lib, ...}:
let
  options = {
    stylix = lib.mkOption {
      type = lib.types.raw;
    };
  };
in
{
  inherit options;
  config = {
    home-manager.sharedModules = [{
      inherit options;
    }];
  };
}
