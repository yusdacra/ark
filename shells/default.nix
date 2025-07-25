{
  lib,
  allPkgsSets,
  ...
}:
lib.mapAttrs (
  system: set:
  let
    inherit (set) pkgs;
    agenix = pkgs.callPackage "${set.inputs.agenix}/pkgs/agenix.nix" { };
    agenix-wrapped = pkgs.writeShellApplication {
      name = "agenix";
      runtimeInputs = [ agenix ];
      text = ''
        if [ -z "''${1-}" ]; then
          agenix
        else
          RULES="$NH_FLAKE/secrets/secrets.nix" agenix -i "$NH_FLAKE/ssh_key" "$@"
        fi
      '';
    };
    commit = pkgs.writers.writeNuBin "commit" ../commit.nu;
    deploy = pkgs.writers.writeNuBin "deploy" ../deploy.nu;
    dash = pkgs.writers.writeNuBin "dash" ./dash.nu;
  in
  {
    default = pkgs.mkShellNoCC {
      name = "prts";
      packages =
        (with pkgs; [
          git
          nixfmt-rfc-style
          treefmt
          rage
          nh
          nvfetcher
          # golangci-lint
          # golangci-lint-langserver
        ])
        ++ [
          agenix-wrapped
          commit
          deploy
        ];
      shellHook = ''
        echo \"$(tput bold)welcome to PRTS, $USER$(tput sgr0)\"
        export NH_FLAKE=$PWD
      '';
    };
    perses = pkgs.mkShellNoCC {
      packages = [dash set.terra.percli pkgs.go pkgs.gopls];
    };
  }
) allPkgsSets
