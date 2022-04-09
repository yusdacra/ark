{
  description = "A highly structured configuration database.";
  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";

    fup.url = "github:gytis-ivaskevicius/flake-utils-plus";

    home.url = "github:nix-community/home-manager/release-21.11";
    home.inputs.nixpkgs.follows = "nixos";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixos";
    };
    naersk.url = "github:nmattia/naersk";
    naersk.inputs.nixpkgs.follows = "nixos";
    nixCargoIntegration.url = "github:yusdacra/nix-cargo-integration";
    nixCargoIntegration.inputs.nixpkgs.follows = "nixos";
    nixCargoIntegration.inputs.rustOverlay.follows = "rust-overlay";

    nixosHardware.url = "github:nixos/nixos-hardware";
    nixosPersistence.url = "github:nix-community/impermanence";

    rnixLsp = {
      url = "github:nix-community/rnix-lsp";
      inputs.naersk.follows = "naersk";
      inputs.nixpkgs.follows = "nixos";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixos";
    };
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixos";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.nixCargoIntegration.follows = "nixCargoIntegration";
    };
  };
  outputs = {
    self,
    fup,
    home,
    nixosHardware,
    nixosPersistence,
    nixpkgsWayland,
    rnixLsp,
    alejandra,
    helix,
    nixos,
    ...
  } @ inputs:
    fup.lib.mkFlake
    {
      inherit self inputs;

      supportedSystems = ["x86_64-linux"];
      channelsConfig.allowUnfree = true;
      nix.generateRegistryFromInputs = true;
      nix.generateNixPathFromInputs = true;
      nix.linkInputs = true;

      sharedOverlays = [
        (_: prev: {
          lib = prev.lib.extend (_: _: builtins);
        })
        (_: prev: {
          lib = prev.lib.extend (_: l: {
            pkgBin = id:
              if l.isString id
              then "${prev.${id}}/bin/${id}"
              else "${prev.${id.name}}/bin/${id.bin}";
          });
        })
      ];

      channels.nixos = {
        overlays = [
          ./overlays/chromium-wayland.nix
          ./overlays/phantom.nix
          (
            _: prev: {
              helix = helix.packages.${prev.system}.helix;
              rnix-lsp = rnixLsp.packages.${prev.system}.rnix-lsp;
              alejandra = alejandra.defaultPackage.${prev.system};
            }
          )
        ];
      };

      hostDefaults = {
        channelName = "nixos";
        modules = [
          home.nixosModules.home-manager
          ./profiles
          ./modules
          ./locale
          ./secrets
        ];
      };

      hosts.lungmen = {
        modules = with nixosHardware.nixosModules; [
          nixos.nixosModules.notDetected
          nixosPersistence.nixosModules.impermanence
          common-pc-ssd
          common-pc
          common-gpu-amd
          common-cpu-amd
          ./profiles/network/networkmanager
          ./users/root
          ./users/patriot
          ./hosts/lungmen
        ];
      };

      outputsBuilder = channels:
        with channels.nixos; {
          devShell = mkShell {
            name = "prts";
            buildInputs = [git git-crypt];
          };
        };
    };
}
