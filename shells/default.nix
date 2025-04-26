{
  tlib,
  inputs,
  ...
}:
tlib.genPkgs (
  pkgs:
  let
    mkNakedShell = pkgs.callPackage inputs.naked-shell { };
    agenix-wrapped = pkgs.writeShellApplication {
      name = "agenix";
      runtimeInputs = [ pkgs.agenix ];
      text = ''
        if [ -z "''${1-}" ]; then
          agenix
        else
          RULES="$FLAKE/secrets/secrets.nix" agenix -i "$FLAKE/ssh_key" "$@"
        fi
      '';
    };
    commit = pkgs.writers.writeNuBin "commit" ../commit.nu;
    deploy = pkgs.writers.writeNuBin "deploy" ../deploy.nu;
  in
  {
    default = mkNakedShell {
      name = "prts";
      packages =
        (with pkgs; [
          git
          nixfmt-rfc-style
          treefmt
          rage
          nh
        ])
        ++ [
          agenix-wrapped
          commit
          deploy
        ];
      shellHook = ''
        echo \"$(tput bold)welcome to PRTS, $USER$(tput sgr0)\"
        export FLAKE=$PWD
      '';
    };
  }
)
