{
  buildGoModule,
  fetchFromGitHub,
  ...
}:
let
  rev = "6818fd27ae5e3644fe7239eb68a1de6447d052c9";
in
buildGoModule {
  pname = "bluesky-tap";
  version = builtins.substring 0 8 rev;

  src = fetchFromGitHub {
    owner = "bluesky-social";
    repo = "indigo";
    inherit rev;
    hash = "sha256-NwfhXpo1uBbJe1w9CKejLEljaiu+5fumJFbD0w9+Aqk=";
  };

  vendorHash = "sha256-UOedwNYnM8Jx6B7Y9tFcZX8IeUBESAFAPTRYk7n0yo8=";

  subPackages = [ "cmd/tap" ];

  ldflags = [ "-s" "-w" ];
}
