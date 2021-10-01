{
  description = "A highly structured configuration database.";

  inputs =
    {
      nixos.url = "github:nixos/nixpkgs/nixos-21.05";
      latest.url = "github:nixos/nixpkgs/nixos-unstable";

      digga.url = "github:divnix/digga/main";
      digga.inputs.nixpkgs.follows = "nixos";
      digga.inputs.nixlib.follows = "nixos";
      digga.inputs.home-manager.follows = "home";

      /*bud.url = "github:divnix/bud";
        bud.inputs.nixpkgs.follows = "nixos";
        bud.inputs.devshell.follows = "digga/devshell";*/

      home.url = "github:nix-community/home-manager/release-21.05";
      home.inputs.nixpkgs.follows = "nixos";

      /*darwin.url = "github:LnL7/nix-darwin";
        darwin.inputs.nixpkgs.follows = "latest";*/

      /*agenix.url = "github:ryantm/agenix";
        agenix.inputs.nixpkgs.follows = "latest";*/

      /*nvfetcher.url = "github:berberman/nvfetcher";
        nvfetcher.inputs.nixpkgs.follows = "latest";
        nvfetcher.inputs.flake-compat.follows = "digga/deploy/flake-compat";
        nvfetcher.inputs.flake-utils.follows = "digga/flake-utils-plus/flake-utils";*/

      naersk.url = "github:nmattia/naersk";
      naersk.inputs.nixpkgs.follows = "latest";

      nixos-hardware.url = "github:nixos/nixos-hardware";

      rnixLsp = {
        url = "github:nix-community/rnix-lsp";
        inputs.naersk.follows = "naersk";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.utils.follows = "flake-utils";
      };
      helix = {
        url = "https://github.com/helix-editor/helix.git";
        type = "git";
        submodules = true;
        inputs.nixpkgs.follows = "nixpkgs";
      };
      nixosPersistence.url = "github:nix-community/impermanence";
      nixpkgsWayland = {
        url = "github:colemickens/nixpkgs-wayland";
        inputs.nixpkgs.follows = "nixos";
      };
      # start ANTI CORRUPTION LAYER
      # remove after https://github.com/NixOS/nix/pull/4641
      nixpkgs.follows = "nixos";
      nixlib.follows = "digga/nixlib";
      blank.follows = "digga/blank";
      flake-utils-plus.follows = "digga/flake-utils-plus";
      flake-utils.follows = "digga/flake-utils";
      # end ANTI CORRUPTION LAYER
    };

  outputs =
    { self
    , digga
      #, bud
    , nixos
    , home
    , nixos-hardware
      #, nur
      #, agenix
      #, nvfetcher
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
              #digga.overlays.patchedNix
              #nur.overlay
              #agenix.overlay
              #nvfetcher.overlay
              #deploy.overlay
              #nixpkgsWayland.overlay
              (_: prev: {
                helix = helix.packages.${prev.system}.helix;
                helix-src = helix;
                rnix-lsp = rnixLsp.packages.${prev.system}.rnix-lsp;
              })
              ./pkgs/default.nix
            ];
          };
          latest = { };
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
              #agenix.nixosModules.age
              #bud.nixosModules.bud
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

        /*defaultTemplate = self.templates.bud;
          templates.bud.path = ./.;
          templates.bud.description = "bud template";*/
      }
    //
    {
      # budModules = { devos = import ./bud; };
    }
  ;
}
