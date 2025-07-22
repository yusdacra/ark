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
    blog.flake = false;

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
      tlib = import ./lib lib;
      l = lib;

      makePkgsSet = system: import ./pkgs-set {
        inherit system inputs lib tlib;
      };
      allPkgsSets = tlib.genSystems makePkgsSet;

      miscApps =
        l.mapAttrs
          (
            _: cmds:
            l.mapAttrs (_: cmd: {
              type = "app";
              program = cmd;
            }) cmds
          )
          (
            l.mapAttrs
            (_: set: (
              l.mapAttrs
              (_: app: app.program)
              (inputs.ncr.makeApps {inherit (set) pkgs; inherit (inputs) self;})
            ) // {
              generate-firefox-addons = toString "${set.pkgs.generate-firefox-addons}/bin/generate-firefox-addons";
              dns = toString "${set.pkgs.dnsmngmt}/bin/dns";
            })
            allPkgsSets
          );
    in
    {
      lib = tlib;
      nixosConfigurations = import ./hosts { inherit lib tlib inputs allPkgsSets; };
      homeConfigurations = import ./users { inherit lib tlib inputs allPkgsSets; };

      packages = l.mapAttrs (_: set: set.exported) allPkgsSets;
      apps = miscApps;

      # topology = lib.mapAttrs (_: pkgs:
      #   import inputs.nixtopo {
      #     inherit pkgs;
      #     modules = [{nixosConfigurations = {inherit (inputs.self.nixosConfigurations) wolumonde;};}];
      #   })
      # allPkgs;

      devShells = import ./shells { inherit lib inputs allPkgsSets; };
    };
}
