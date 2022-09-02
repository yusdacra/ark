{
  description = "config!!!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    home.url = "github:nix-community/home-manager/master";
    home.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-persistence.url = "github:nix-community/impermanence";

    nixinate.url = "github:matthewcroughan/nixinate";
    nixinate.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix";
    hyprland.url = "github:hyprwm/Hyprland";
    fufexan.url = "github:fufexan/dotfiles";
    fufexan.inputs.hyprland.follows = "hyprland";
    blog.url = "git+https://git.gaze.systems/dusk/website.git";
    blog.inputs.nixpkgs.follows = "nixpkgs";
    bernbot.url = "github:yusdacra/bernbot";
    bernbot.inputs.nixpkgs.follows = "nixpkgs";
    discocss.url = "github:fufexan/discocss/flake";
    discocss.inputs.nixpkgs.follows = "nixpkgs";
    nil.url = "github:oxalica/nil";
    nil.inputs.nixpkgs.follows = "nixpkgs";
    webcord.url = "github:fufexan/webcord-flake/system-electron";
    webcord.inputs.nixpkgs.follows = "nixpkgs";
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

    allPkgs = tlib.genPkgs (x: x);

    miscApps =
      lib.mapAttrs
      (
        _: pkgs: {
          generate-firefox-addons = {
            type = "app";
            program =
              toString
              "${pkgs.generate-firefox-addons}/bin/generate-firefox-addons";
          };
        }
      )
      allPkgs;
  in {
    nixosConfigurations = import ./hosts {inherit lib tlib inputs;};

    packages = lib.mapAttrs (_: pkgs: pkgs._exported) allPkgs;
    legacyPackages = allPkgs;
    apps = miscApps // (inputs.nixinate.nixinate.x86_64-linux inputs.self);

    devShells = import ./shells {inherit lib tlib inputs;};
  };
}
