{
  description = "config!!!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home.url = "github:nix-community/home-manager/master";
    home.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-persistence.url = "github:nix-community/impermanence";

    smos.url = "github:yusdacra/smos/chore/fix-nix-flakes";
    smos.flake = false;
  };

  outputs = inputs: let
    lib = inputs.nixpkgs.lib.extend (_: _: builtins);
    tlib = (import ./lib lib).extend (_: prev: rec {
      makePkgs = system:
        import ./pkgs-set {
          inherit system lib inputs;
          tlib = prev;
        };
      genPkgs = f: prev.genSystems (system: f (makePkgs system));
    });
  in rec {
    nixosConfigurations = import ./hosts {inherit lib tlib inputs;};

    packages = tlib.genPkgs (pkgs: pkgs._exported);

    devShells = import ./shells {inherit lib tlib inputs;};
  };
}
