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
          go
          gopls
          nvfetcher
          # golangci-lint
          # golangci-lint-langserver
        ])
        ++ [
          dash
          agenix-wrapped
          commit
          deploy
          set.terra.percli
        ];
      shellHook = ''
        echo \"$(tput bold)welcome to PRTS, $USER$(tput sgr0)\"
        export NH_FLAKE=$PWD
      '';
    };
  }
) allPkgsSets
