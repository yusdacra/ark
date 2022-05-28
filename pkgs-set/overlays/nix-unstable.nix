{inputs}: _: prev: {
  nix = inputs.nix.packages.${prev.system}.nix.overrideAttrs (old: {
    doCheck = false;
    doInstallCheck = false;
  });
}
