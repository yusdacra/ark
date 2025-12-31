final: prev: let
  nixpkgs = final.fetchFromGitHub {
    owner = "nixos";
    repo = "nixpkgs";
    rev = "704f35db2a9090fb91098735e337722e2921e806";
    hash = "sha256-U4eCiVMdkbVVaxepH76mDF6vTQ6qLLT8BYyS0G34i4s=";
  };
in {
  feishin = prev.callPackage "${nixpkgs}/pkgs/by-name/fe/feishin/package.nix" {};
}
