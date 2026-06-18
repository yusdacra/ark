{ inputs, callPackage, ... }: (callPackage "${inputs.tangled}/nix/pkgs/bobbin.nix" {
  src = inputs.tangled;
}).overrideAttrs (old: {
  postUnpack = ''
    substituteInPlace $sourceRoot/Cargo.toml \
      --replace-fail 'rust-version = "1.96"' 'rust-version = "1.95"'
  '';
})
