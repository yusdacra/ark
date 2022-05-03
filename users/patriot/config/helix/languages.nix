{pkgBin, ...}: ''
  [[language]]
  name = "nix"
  language-server = { command = "${pkgBin "rnix-lsp"}" }
  [[language]]
  name = "dockerfile"
  roots = ["Dockerfile", "Containerfile"]
  file-types = ["Dockerfile", "Containerfile", "dockerfile", "containerfile"]
''
