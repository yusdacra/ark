{
  buildGoModule,
  fetchFromGitHub,
  ...
}:
let
  pname = "percli";
  version = "0.51.0-beta.1";

  src = fetchFromGitHub {
    owner = "perses";
    repo = "perses";
    tag = "v${version}";
    hash = "sha256-tub9W9ZOv1CDaZb/4JPg98HhfBqpVDSBQ6GNR8fBJ1Y=";
  };
in
buildGoModule {
  inherit pname version src;

  CGO_ENABLED = 0;

  subPackages = [ "cmd/percli" ];

  vendorHash = "sha256-2qtyEIzMu3UIDbsqhpAJDVYr7WGmE6H3ngN74HaON04=";
}
