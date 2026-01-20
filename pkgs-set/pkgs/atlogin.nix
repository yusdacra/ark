{
  buildGoModule,
  fetchFromGitHub,
  ...
}:
let
  rev = "943b11de2f5592a6680a826c67e763f292c664ff";
in
buildGoModule {
  pname = "atlogin";
  version = builtins.substring 0 8 rev;

  src = fetchFromGitHub {
    owner = "apenwarr";
    repo = "atlogin";
    inherit rev;
    hash = "sha256-E4B1zj3jYxVw9LKxLkJjNwa72UfrrkRJj4sxPnHhdsA=";
  };

  vendorHash = "sha256-bmoNRyzxIKZmz7hzDKhMSulYZ67PmqpnDzYxtTQhI0o=";

  subPackages = ["cmd/atlogin"];

  ldflags = ["-s" "-w"];
}