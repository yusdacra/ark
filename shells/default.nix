{lib, ...}:
lib.genPkgs (pkgs: {
  default = with pkgs;
    mkShell {
      name = "prts";
      buildInputs = [git git-crypt];
      shellHook = "echo \"$(tput bold)welcome to PRTS, $USER$(tput sgr0)\"";
    };
})
