{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = let
    b = builtins;
    modules = toString ./modules;
    files = b.readDir modules;
    filesToImport =
      b.map (name: "${modules}/${name}") (b.attrNames files);
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
