{pkgs, fetchFromGitHub, ...}: pkgs.beads.overrideAttrs (old: rec {
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "gastownhall";
    repo = "beads";
    tag = "v${version}";
    hash = "sha256-+dFV//0N8ZDw9BHOJOoWZ+BvLmJKlnGtONHIYPRhfBE=";
  };
  vendorHash = "sha256-WWEwGpCwMPD7jaz02zN745RQQqYTQttehbcT3J9hayM=";
  doCheck = false;
})
