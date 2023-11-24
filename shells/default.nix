{tlib, inputs, ...}:
tlib.genPkgs (pkgs: let
  mkNakedShell = pkgs.callPackage inputs.naked-shell {};
  agenix-wrapped = pkgs.writeShellApplication {
    name = "agenix";
    runtimeInputs = [pkgs.agenix];
    text = ''
      if [ -z "''${1-}" ]; then
        agenix
      else
        RULES="/etc/nixos/secrets/secrets.nix" agenix -i /persist/keys/ssh_key "$@"
      fi
    '';
  };
in {
  default =
    mkNakedShell {
      name = "prts";
      packages = with pkgs; [git git-crypt alejandra helix agenix-wrapped rage];
      shellHook = ''
        echo \"$(tput bold)welcome to PRTS, $USER$(tput sgr0)\"
      '';
    };
})
