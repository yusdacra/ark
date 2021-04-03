inputs@{ home, impermanence, mynex, nixpkgs, self, pkgs, system, ... }:
let
  utils = import ../lib/utils.nix { inherit lib pkgs; };

  inherit (nixpkgs) lib;
  inherit (utils) recImport;

  config = hostName:
    lib.nixosSystem {
      inherit system;

      specialArgs = {
        usr = { inherit utils; };
        util = utils;
        nixosPersistence = "${impermanence}/nixos.nix";
        nixpkgsFlake = nixpkgs;
      };

      modules =
        let
          inherit (home.nixosModules) home-manager;
          inherit (mynex.nixosModules) security networking;

          core = ../profiles/core.nix;

          global = {
            networking.hostName = hostName;
            nix = {
              nixPath = [
                "nixpkgs=${nixpkgs}"
                "nixos-config=/etc/nixos/configuration.nix"
                "nixpkgs-overlays=/etc/nixos/overlays"
              ];

              binaryCachePublicKeys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
              ];
              binaryCaches = [
                "https://cache.nixos.org"
                "https://nixpkgs-wayland.cachix.org"
              ];
            };

            nixpkgs = { inherit pkgs; };
          };

          local = import "${toString ./.}/${hostName}.nix";
        in
        [ core global local home-manager security networking ];
    };

  hosts = recImport {
    dir = ./.;
    _import = config;
  };
in
hosts
