{
  buildGoModule,
  fetchFromGitHub,
  ...
}:
let
  rev = "9cf6b7ee3c3a8a8d768b76bc957ef953fa897486";
in
buildGoModule {
  pname = "bluesky-tap";
  version = builtins.substring 0 8 rev;

  src = fetchFromGitHub {
    owner = "bluesky-social";
    repo = "indigo";
    inherit rev;
    hash = "sha256-f5CK4dyyMRfTi54y8maVpKbpJMfkc/0JVlu48lQ7UjQ=";
  };

  # patches = [./tap_deadlock_fix.patch];

  vendorHash = "sha256-s1S+b+QbptqJ2mxqkvsn7M5VWfLrlwpWgRjg6lq2WVE=";

  subPackages = [ "cmd/tap" ];

  ldflags = [ "-s" "-w" ];
}
