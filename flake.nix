{
  description = "config!!!";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/release-21.11";
    latest.url = "github:nixos/nixpkgs/nixos-unstable";

    home.url = "github:nix-community/home-manager/release-21.11";
    home.inputs.nixpkgs.follows = "nixos";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-persistence.url = "github:nix-community/impermanence";
  };

  outputs = inputs: let
    lib = (import ./lib inputs.nixos.lib).extend (_: lib: rec {
      makePkgs = system:
        import ./pkgs-set {
          inherit system lib;
          stable = inputs.nixos;
          unstable = inputs.latest;
        };
      genPkgs = f: lib.genSystems (system: f (makePkgs system));
    });
  in rec {
    nixosConfigurations = import ./hosts {inherit lib inputs;};
    devShells = import ./shells {inherit lib inputs;};
    devShell = lib.mapAttrs (_: value: value.default) devShells;
  };
}
