{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  nix = {
    registry =
      builtins.mapAttrs
      (_: v: {flake = v;})
      (lib.filterAttrs (_: v: v ? outputs) inputs);
    package = pkgs.nix;
    gc.automatic = false;
    optimise.automatic = true;
    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
      extra-experimental-features = nix-command flakes
      builders-use-substitutes = true
      netrc-file = /etc/nix/netrc
    '';
    nixPath = ["nixpkgs=${inputs.nixpkgs}" "home-manager=${inputs.home}"];
  };
  nix.settings = {
    sandbox = true;
    allowed-users = ["@wheel"];
    trusted-users = ["root" "@wheel"];
    auto-optimise-store = true;
  };
}
