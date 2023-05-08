{
  description = "config!!!";

  inputs = {
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    home.url = "github:nix-community/home-manager/master";
    home.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-persistence.url = "github:nix-community/impermanence";

    nixinate.url = "github:matthewcroughan/nixinate";
    nixinate.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixpkgs-wayland.flake = false;

    helix.url = "github:helix-editor/helix";

    blog.url = "git+https://git.gaze.systems/dusk/website.git";
    blog.inputs.nixpkgs.follows = "nixpkgs";

    bernbot.url = "github:yusdacra/bernbot";
    bernbot.inputs.nixpkgs.follows = "nixpkgs";

    blender-bin.url = "github:edolstra/nix-warez?dir=blender";
    blender-bin.inputs.nixpkgs.follows = "nixpkgs";

    conduit.url = "gitlab:famedly/conduit";
    conduit.inputs.nixpkgs.follows = "nixpkgs";

    nil.url = "github:oxalica/nil";
    nil.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:yusdacra/stylix/fixed";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.home-manager.follows = "home";

    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    musikquad.url = "github:yusdacra/musikquadrupled";
    musikquad.inputs.nixpkgs.follows = "nixpkgs";

    musikspider.url = "github:yusdacra/musikspider";
    musikspider.inputs.nixpkgs.follows = "nixpkgs";

    # needed for hyprland setup
    # hyprland.url = "github:hyprwm/Hyprland";
    # hyprland.inputs.nixpkgs.follows = "nixpkgs";
    # hyprland-contrib.url = "github:hyprwm/contrib";
    # hyprland-contrib.inputs.nixpkgs.follows = "nixpkgs";
    # eww.url = "github:elkowar/eww";
    # eww.inputs.nixpkgs.follows = "nixpkgs";

    # catppuccin-discord.url = "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css";
    # catppuccin-discord.flake = false;
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
    lib = tlib;
    nixosConfigurations = import ./hosts {inherit lib tlib inputs;};

    packages = lib.mapAttrs (_: pkgs: pkgs._exported) allPkgs;
    legacyPackages = allPkgs;
    apps = miscApps // (inputs.nixinate.nixinate.x86_64-linux inputs.self);

    devShells = import ./shells {inherit lib tlib inputs;};
  };
}
