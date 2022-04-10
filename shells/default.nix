{tlib, ...}:
tlib.genPkgs (pkgs: {
  default = with pkgs;
    mkShell {
      name = "prts";
      buildInputs = [git git-crypt alejandra helix];
      shellHook = "echo \"$(tput bold)welcome to PRTS, $USER$(tput sgr0)\"";
    };
})
