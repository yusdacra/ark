{ pkgs, ... }:
{
  users.users.root.initialHashedPassword = "$6$XLWo1sPpgp63Zm$XHBbULH9q1gb/.yalPPU/I7EgTcW80bM.moCjIe/qGyOwE47VcXNVbTHloBZdIWQq0MfIG0IxInAu59.oJyos/";
  environment.systemPackages = [pkgs.nushell];
  users.users.root.shell = pkgs.nushell;
  home-manager.users.root = {
    imports = [../modules/nushell];
  };
}
