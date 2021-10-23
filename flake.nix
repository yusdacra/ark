{
  description = "A highly structured configuration database.";

  nixConfig.extra-experimental-features = "nix-command flakes ca-references";
  nixConfig.extra-substituters = "https://nrdxp.cachix.org https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys = "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

  inputs =
    {
      nixos.url = "github:nixos/nixpkgs/nixos-unstable";

      digga.url = "github:divnix/digga/main";
      digga.inputs.nixpkgs.follows = "nixos";
      digga.inputs.nixlib.follows = "nixos";
      digga.inputs.home-manager.follows = "home";

      home.url = "github:nix-community/home-manager/master";
      home.inputs.nixpkgs.follows = "nixos";

      naersk.url = "github:nmattia/naersk";
      naersk.inputs.nixpkgs.follows = "nixos";

      nixos-hardware.url = "github:nixos/nixos-hardware";

      rnixLsp = {
        url = "github:nix-community/rnix-lsp";
        inputs.naersk.follows = "naersk";
        inputs.nixpkgs.follows = "nixos";
        inputs.utils.follows = "digga/flake-utils";
      };
      helix = {
        url = "https://github.com/helix-editor/helix.git";
        type = "git";
        submodules = true;
        inputs.nixpkgs.follows = "nixos";
      };
      nixosPersistence.url = "github:nix-community/impermanence";
      nixpkgsWayland = {
        url = "github:colemickens/nixpkgs-wayland";
        inputs.nixpkgs.follows = "nixos";
      };
    };

  outputs =
    { self
    , digga
    , nixos
    , home
    , nixos-hardware
    , nixosPersistence
    , nixpkgsWayland
    , rnixLsp
    , helix
    , ...
    } @ inputs:
    digga.lib.mkFlake
      {
        inherit self inputs;

        channelsConfig = { allowUnfree = true; };

        channels = {
          nixos = {
            imports = [ (digga.lib.importOverlays ./overlays) ];
            overlays = [
              #nixpkgsWayland.overlay
              (_: prev: {
                helix = helix.packages.${prev.system}.helix;
                helix-src = prev.helix.src;
                rnix-lsp = rnixLsp.packages.${prev.system}.rnix-lsp;
              })
              ./pkgs/default.nix
            ];
          };
        };

        lib = import ./lib { lib = digga.lib // nixos.lib; };

        sharedOverlays = [
          (_: prev: {
            __dontExport = true;
            lib = prev.lib.extend (_: _: {
              our = self.lib;
            });
          })
        ];

        nixos = {
          hostDefaults = {
            system = "x86_64-linux";
            channelName = "nixos";
            imports = [ (digga.lib.importExportableModules ./modules) ];
            modules = [
              { lib.our = self.lib; }
              digga.nixosModules.bootstrapIso
              digga.nixosModules.nixConfig
              home.nixosModules.home-manager
              nixosPersistence.nixosModules.impermanence
            ];
          };

          imports = [ (digga.lib.importHosts ./hosts) ];
          hosts = { };
          importables = rec {
            profiles = (digga.lib.rakeLeaves ./profiles) // {
              users = digga.lib.rakeLeaves ./users;
              nixos-hardware = nixos-hardware.nixosModules;
            };
            suites = with profiles; {
              base = [ cachix core users.root ];
              work = [ users.patriot develop ];
            };
          };
        };

        home = {
          imports = [ (digga.lib.importExportableModules ./users/modules) ];
          modules = [ ];
          importables = rec {
            profiles = digga.lib.rakeLeaves ./users/profiles;
            suites = with profiles; rec {
              base = [ direnv git starship ];
            };
          };
        };

        devshell = ./shell;

        homeConfigurations = digga.lib.mkHomeConfigurations self.nixosConfigurations;

        deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations { };
      }
  ;
}
