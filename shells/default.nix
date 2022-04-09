{lib, ...}:
lib.genPkgs (pkgs: {
  default = with pkgs;
    mkShell {
      name = "prts";
      buildInputs = [git git-crypt];
      shellHook = "echo welcome to PRTS, $USER";
    };
})
