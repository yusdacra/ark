{
  description = "config!!!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.2-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    home.url = "github:nix-community/home-manager/master";
    home.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-persistence.url = "github:nix-community/impermanence";

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixpkgs-wayland.flake = false;

    blog.url = "git+https://git.gaze.systems/90008/website.git";
    # blog.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    limbusart.url = "git+https://git.gaze.systems/dusk/limbusart.git";
    # limbusart.inputs.nixpkgs.follows = "nixpkgs";

    naked-shell.url = "github:yusdacra/mk-naked-shell";
    naked-shell.flake = false;

    tangled.url = "git+https://tangled.sh/@tangled.sh/core";
    tangled.inputs.nixpkgs.follows = "nixpkgs";

    ncr.url = "git+https://tangled.sh/@poor.dog/nixos-cloud-resources";
    ncr.inputs.nixpkgs.follows = "nixpkgs";

    nsid-tracker.url = "git+https://tangled.sh/@poor.dog/nsid-tracker";
    nsid-tracker.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    let
      lib = inputs.nixpkgs.lib;
      tlib = (import ./lib lib).extend (
        _: prev: rec {
          makePkgs =
            system:
            import ./pkgs-set {
              inherit system lib inputs;
              tlib = prev;
            };
          genPkgs = f: prev.genSystems (system: f (makePkgs system));
        }
      );

      allPkgs = tlib.genPkgs (x: x);

      miscApps =
        lib.mapAttrs
          (
            _: cmds:
            lib.mapAttrs (_: cmd: {
              type = "app";
              program = cmd;
            }) cmds
          )
          (
            lib.mapAttrs
            (_: pkgs: (
              lib.mapAttrs
              (_: app: app.program)
              (inputs.ncr.makeApps {inherit pkgs; inherit (inputs) self;})
            ) // {
              generate-firefox-addons = toString "${pkgs.generate-firefox-addons}/bin/generate-firefox-addons";
              dns = toString "${pkgs.dnsmngmt}/bin/dns";
            })
            allPkgs
          );
    in
    {
      lib = tlib;
      nixosConfigurations = import ./hosts { inherit lib tlib inputs allPkgs; };
      homeConfigurations = import ./users { inherit lib tlib inputs allPkgs; };

      packages = lib.mapAttrs (_: pkgs: pkgs._exported) allPkgs;
      legacyPackages = allPkgs;
      apps = miscApps;

      # topology = lib.mapAttrs (_: pkgs:
      #   import inputs.nixtopo {
      #     inherit pkgs;
      #     modules = [{nixosConfigurations = {inherit (inputs.self.nixosConfigurations) wolumonde;};}];
      #   })
      # allPkgs;

      devShells = import ./shells { inherit lib tlib inputs; };
    };
}
