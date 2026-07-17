{ inputs, pkgs, terra, ... }:
{
  users.users.root = {
#    shell = pkgs.nushell;
    initialHashedPassword = "$6$XLWo1sPpgp63Zm$XHBbULH9q1gb/.yalPPU/I7EgTcW80bM.moCjIe/qGyOwE47VcXNVbTHloBZdIWQq0MfIG0IxInAu59.oJyos/";
    openssh.authorizedKeys.keys = [
      (builtins.readFile "${inputs.self}/secrets/yusdacra.key.pub")
      (builtins.readFile "${inputs.self}/secrets/roka.key.pub")
    ];
  };

  environment.systemPackages = [pkgs.bashInteractive pkgs.nushell terra.codex];
  home-manager.users.root = {
    imports = [ ../modules/nushell ];
  };
}
