{
  inputs,
  path,
  writers,
  system,
  ...
}:
writers.writeNuBin "deploy-resources" ''
  use std/log
  nix eval --json .#nixosConfigurations --apply builtins.attrNames | from json
    | each {|system|
        let cfgNames = nix eval --json $".#nixosConfigurations.($system).config" --apply builtins.attrNames | from json
        if not ($cfgNames | any {|el| $el == "providers"}) {
          return
        }
        let expr = '
          let
            flake = builtins.getFlake "path:${inputs.self}?narHash=${inputs.self.narHash}";
            ncr = flake.legacyPackages.${system}.inputs.ncr;
          in
            (import (ncr + "/makeApps.nix") {
              pkgs = flake.legacyPackages.${system};
              nixosSystem = flake.nixosConfigurations.<system>;
            }).run
        ' | str replace "<system>" $system
        log info $"deploying resources for ($system)"
        nix build --json --expr $expr | from json | get 0.outputs.out
          | each {|out| try {nu $out}}
      }
  exit 0
''
