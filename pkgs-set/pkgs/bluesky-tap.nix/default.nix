{
  buildGoModule,
  fetchFromGitHub,
  ...
}:
let
  rev = "1286ca7a7cb25ece0e7d49648b7655cc285aee0f";
in
buildGoModule {
  pname = "bluesky-tap";
  version = builtins.substring 0 8 rev;

  src = fetchFromGitHub {
    owner = "bluesky-social";
    repo = "indigo";
    inherit rev;
    hash = "sha256-yksMw5ommI+ewvfudlpfMpSWUtpP3GC4XwnmmSYT7ks=";
  };

  # patches = [./tap_deadlock_fix.patch];

  vendorHash = "sha256-KRR+8icVuMGBQlR8h4KE6rpWWj9lrkNOJlxbFLyFsUI=";

  subPackages = [ "cmd/tap" ];

  ldflags = [ "-s" "-w" ];
}
