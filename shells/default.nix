{tlib, ...}:
tlib.genPkgs (pkgs: let
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
  default = with pkgs;
    mkShell {
      name = "prts";
      buildInputs = [git git-crypt alejandra helix agenix-wrapped rage];
      shellHook = ''
        echo \"$(tput bold)welcome to PRTS, $USER$(tput sgr0)\"
      '';
    };
})
