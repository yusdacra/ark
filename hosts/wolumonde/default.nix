{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = let
    files =
      lib.filterAttrs
      (name: type: type == "regular" && name != "default.nix")
      (builtins.readDir (toString ./.));
    filesToImport =
      builtins.map
      (
        name:
          builtins.path {
            inherit name;
            path = "${toString ./.}/${name}";
          }
      )
      (builtins.attrNames files);
  in
    filesToImport;

  boot.cleanTmpDir = true;
  zramSwap.enable = true;

  # firewall stuffs
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443];
    allowedUDPPortRanges = [];
  };

  system.stateVersion = "22.05";
}
