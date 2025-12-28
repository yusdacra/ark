final: prev: let
  nixpkgs = final.fetchFromGitHub {
    owner = "nixos";
    repo = "nixpkgs";
    rev = "70adf772dca7804ba7b5701f5b20c01108b83401";
    hash = "sha256-AJjEVxNQnmPucS/t9roICpfPsBDjuNoSeQ1YGP40/gM=";
  };
in {
  feishin = prev.callPackage "${nixpkgs}/pkgs/by-name/fe/feishin/package.nix" {};
}
