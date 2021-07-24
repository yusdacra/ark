final: prev:
let
  nixpkgsSrc = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/d8f8f31af9d77a48220e4e8a301d1e79774cb7d2.tar.gz";
    sha256 = "sha256:1laghvd60pmlpiqm182qb658rs4k6d88id25n9byh0d1gxl2rpv6";
  };
  nixpkgs = import nixpkgsSrc {
    inherit (prev) system config;
  };
in
{
  chromium = nixpkgs.chromium;
}
