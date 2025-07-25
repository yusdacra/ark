{
  description = "config!!!";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nixpkgs.flake = false;

  outputs =
    flakeInputs:
    let
      lib = import "${flakeInputs.nixpkgs}/lib";
      tlib = import ./lib lib;
      l = lib;

      makePkgsSet =
        system:
        import ./pkgs-set {
          inherit
            system
            lib
            tlib
            flakeInputs
            ;
        };
      allPkgsSets = tlib.genSystems makePkgsSet;

      miscApps =
        l.mapAttrs
          (
            _:
            l.mapAttrs (
              _: cmd: {
                type = "app";
                program = cmd;
              }
            )
          )
          (
            l.mapAttrs (_: set: {
              deploy-ncr = l.getExe set.terra.deploy-ncr;
              dns = l.getExe set.terra.dnsmngmt;
            }) allPkgsSets
          );
    in
    {
      lib = tlib;
      nixosConfigurations = import ./hosts { inherit lib tlib allPkgsSets; };
      homeConfigurations = import ./users { inherit lib tlib allPkgsSets; };

      legacyPackages = l.mapAttrs (_: set: set.pkgs // { inherit (set) inputs; }) allPkgsSets;
      packages = l.mapAttrs (_: set: set.exported) allPkgsSets;
      apps = miscApps;

      # topology = lib.mapAttrs (_: pkgs:
      #   import inputs.nixtopo {
      #     inherit pkgs;
      #     modules = [{nixosConfigurations = {inherit (inputs.self.nixosConfigurations) wolumonde;};}];
      #   })
      # allPkgs;

      devShells = import ./shells { inherit lib allPkgsSets; };
    };
}
