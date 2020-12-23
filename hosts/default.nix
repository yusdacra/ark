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
      };

      modules =
        let
          inherit (home.nixosModules) home-manager;
          inherit (mynex.nixosModules) security networking;

          core = ../profiles/core.nix;

          global = {
            networking.hostName = hostName;
            nix.nixPath = [
              "nixpkgs=${nixpkgs}"
              "nixos-config=/etc/nixos/configuration.nix"
              "nixpkgs-overlays=/etc/nixos/overlays"
            ];

            nixpkgs = { inherit pkgs; };
            nixpkgs.overlays = [ mynex.overlay ];
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
