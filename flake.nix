{
  description = "config!!!";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-21.11";
    latest.url = "github:nixos/nixpkgs/nixos-unstable";

    home.url = "github:nix-community/home-manager/release-21.11";
    home.inputs.nixpkgs.follows = "nixos";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-persistence.url = "github:nix-community/impermanence";
  };

  outputs = inputs: let
    lib = inputs.nixos.lib.extend (_: _: builtins);
    tlib = (import ./lib lib).extend (_: prev: rec {
      makePkgs = system:
        import ./pkgs-set {
          inherit system lib;
          tlib = prev;
          stable = inputs.nixos;
          unstable = inputs.latest;
        };
      genPkgs = f: prev.genSystems (system: f (makePkgs system));
    });
  in rec {
    nixosConfigurations = import ./hosts {inherit lib tlib inputs;};

    packages = tlib.genPkgs (pkgs: pkgs._exported);

    devShells = import ./shells {inherit lib tlib inputs;};
    devShell = lib.mapAttrs (_: value: value.default) devShells;
  };
}
