{pkgBin, ...}: ''
  [[language]]
  name = "nix"
  language-server = { command = "${pkgBin "rnix-lsp"}" }
''
