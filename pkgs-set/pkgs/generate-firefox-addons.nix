{
  nur,
  treefmt,
  writers,
  tlib,
  ...
}:
writers.writeBashBin "generate-firefox-addons" ''
  ${tlib.pkgBin nur.repos.rycee.mozilla-addons-to-nix} \
    users/modules/firefox/extensions.json \
    users/modules/firefox/extensions.nix
  ${tlib.pkgBin treefmt}
''
