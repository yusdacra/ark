{
  buildGoModule,
  fetchFromGitHub,
  ...
}:
let
  pname = "percli";
  version = "0.50.3";

  src = fetchFromGitHub {
    owner = "perses";
    repo = "perses";
    tag = "v${version}";
    hash = "sha256-E8PTPit9QLPMlLvdx8rbw0BwC+ZqSMTHdfPJ4aE4dsw=";
  };
in
buildGoModule {
  inherit pname version src;

  env.CGO_ENABLED = 0;

  subPackages = [ "cmd/percli" ];

  vendorHash = "sha256-yUqV6pBl6tyE4f4tBVN0DwgVFey+1btVpK7eiMKkwIY=";
}
