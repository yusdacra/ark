{
  buildGoModule,
  fetchFromGitHub,
  ...
}:
let
  rev = "131be32d6fc1a9d2788d5c729e3c83c11010a2bb";
in
buildGoModule {
  pname = "bluesky-tap";
  version = builtins.substring 0 8 rev;

  src = fetchFromGitHub {
    owner = "bluesky-social";
    repo = "indigo";
    inherit rev;
    hash = "sha256-wYQ9BV1gZ6GG3vqwJ4Rqg0fZEUn+OV87ifETQVdmofw=";
  };

  patches = [./tap_deadlock_fix.patch];

  vendorHash = "sha256-UOedwNYnM8Jx6B7Y9tFcZX8IeUBESAFAPTRYk7n0yo8=";

  subPackages = [ "cmd/tap" ];

  ldflags = [ "-s" "-w" ];
}
