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
        ])
        ++ [ agenix-wrapped ];
      shellHook = ''
        echo \"$(tput bold)welcome to PRTS, $USER$(tput sgr0)\"
      '';
    };
  }
)
