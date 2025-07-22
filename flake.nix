{
  description = "config!!!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.flake = false;
    nixpkgs-flake.url = "github:nixos/nixpkgs/nixos-unstable";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.2-1.tar.gz";
      flake = false;
    };

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.flake = false;

    home.url = "github:nix-community/home-manager/master";
    home.flake = false;

    blog.url = "git+https://git.gaze.systems/90008/website.git";
    blog.flake = false;

    agenix.url = "github:ryantm/agenix";
    agenix.flake = false;

    naked-shell.url = "github:yusdacra/mk-naked-shell";
    naked-shell.flake = false;

    ncr.url = "git+https://tangled.sh/@poor.dog/nixos-cloud-resources";
    ncr.flake = false;

    limbusart.url = "git+https://git.gaze.systems/90008/limbusart.git";
    limbusart.flake = false;

    nsid-tracker.url = "git+https://tangled.sh/@poor.dog/nsid-tracker";
    nsid-tracker.flake = false;

    tangled.url = "git+https://tangled.sh/@poor.dog/core";
    tangled.flake = false;

    tangled-sqlite-lib = {
      url = "https://sqlite.org/2024/sqlite-amalgamation-3450100.zip";
      flake = false;
    };

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      flake = false;
    };
  };

  outputs =
    inputs:
    let
      lib = import "${inputs.nixpkgs}/lib";
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
              (import "${inputs.ncr}/makeApps.nix" {inherit (set) pkgs; inherit (inputs) self;})
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
