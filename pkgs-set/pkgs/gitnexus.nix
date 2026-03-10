{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  git,
  python3,
  ...
}:
buildNpmPackage rec {
  pname = "gitnexus";
  version = "1.3.10";

  src = fetchFromGitHub {
    owner = "abhigyanpatwari";
    repo = "GitNexus";
    rev = "v${version}";
    hash = "sha256-GfY1PrAFgeDG5LYudK1jZ0Ovi50pyqLOvVYI6RPhN1c=";
  };
  sourceRoot = "${src.name}/gitnexus";

  npmDepsHash = "sha256-4niBbBr1/anaNdhZ+LEyZiZS6W60NYuHmbQMupI31uk=";
  outputHash = "";
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";

  nativeBuildInputs = [git python3];

  meta = {
    description = "graph-powered code intelligence engine — index any codebase, query via MCP or CLI";
    homepage = "https://github.com/abhigyanpatwari/GitNexus";
    license = lib.licenses.mit;
    mainProgram = "gitnexus";
    platforms = lib.platforms.unix;
  };
}
