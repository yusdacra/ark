{
  nur,
  treefmt,
  writers,
  ...
}:
writers.writeBashBin "generate-firefox-addons" ''
  ${nur.repos.rycee.firefox-addons-generator}/bin/nixpkgs-firefox-addons \
    users/modules/firefox/extensions.json \
    users/modules/firefox/extensions.nix
  ${treefmt}/bin/treefmt
''
