{pkgs, fetchFromGitHub, ...}: pkgs.beads.overrideAttrs (old: rec {
  version = "1.0.4";
  src = fetchFromGitHub {
    owner = "gastownhall";
    repo = "beads";
    tag = "v${version}";
    hash = "sha256-a356lk3dWJg2VzXmvBL0xVYUMgICDY/6s6A5km8cjBU=";
  };
  vendorHash = "sha256-gTOYABrdQ9T5uxW5QEE8hRWH6AnCPFE/hbB2t1OJTrY=";
  doCheck = false;
})
