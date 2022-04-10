{
  pkgs,
  lib,
  inputs,
  ...
}: {
  nix = {
    registry = builtins.mapAttrs (_: v: {flake = v;}) (lib.filterAttrs (_: v: v ? outputs) inputs);
    package = pkgs.nixUnstable;
    gc.automatic = true;
    optimise.automatic = true;
    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
      extra-experimental-features = nix-command flakes
    '';
    useSandbox = true;
    allowedUsers = ["@wheel"];
    trustedUsers = ["root" "@wheel"];
    autoOptimiseStore = true;
    nixPath = ["nixpkgs=${inputs.latest}" "home-manager=${inputs.home}"];
  };
}
