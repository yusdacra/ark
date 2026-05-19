{
  python3Packages,
  ast-grep,
  onnxruntime,
  ...
}:
python3Packages.callPackage (
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  litellm,
  tiktoken,
  pydantic,
  click,
  rich,
  opentelemetry-api,
  ast-grep-py,
  python,
  magika,
  mcp,
  fastapi,
  uvicorn,
  httpx,
  h2,
  openai,
  zstandard,
  websockets,
  onnxruntime,
  transformers,
  watchdog,
  sqlite-vec,
  rtk,
  rustPlatform,
  onnxruntimeBin,
  pkg-config,
  pythonRelaxDepsHook,
  ...
}:
let
ast-grep-cli = buildPythonPackage rec {
  pname = "ast-grep-cli";
  version = ast-grep.version;
  format = "other";
  dontUnpack = true;
  dontBuild = true;
  propagatedBuildInputs = [ ast-grep ];
  installPhase = ''
    dist=$out/${python.sitePackages}/ast_grep_cli-${version}.dist-info
    mkdir -p $dist
    printf 'Metadata-Version: 2.1\nName: ast-grep-cli\nVersion: ${version}\n' \
      > $dist/METADATA
    touch $dist/RECORD
  '';
};
in
buildPythonPackage rec {
  pname = "headroom-ai";
  version = "0.21.36";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chopratejas";
    repo = "headroom";
    rev = "v${version}";
    hash = "sha256-XXCuie9NPrQO0gXLv3+qtVScBowxlSXf2tsM69M9jDU=";
  };

  env.ORT_LIB_LOCATION = "${onnxruntimeBin}/lib";
  env.ORT_PREFER_DYNAMIC_LINK = "1";

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
    pkg-config
    pythonRelaxDepsHook
  ];
  buildInputs = [onnxruntimeBin];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-WQBvil0bsS6/Z6b+uRauwOQq4VZ57VwAoghcyFdVgLE=";
  };

  makeWrapperArgs = [
    "--set PYTHONPATH ${python.pkgs.makePythonPath dependencies}"
  ];

  pythonRelaxDeps = ["litellm"];

  dependencies = [
    tiktoken
    pydantic
    click
    rich
    litellm
    ast-grep-py
    ast-grep-cli
    opentelemetry-api
    magika
    mcp
    fastapi
    uvicorn
    httpx
    h2
    openai
    zstandard
    websockets
    onnxruntime
    transformers
    watchdog
    sqlite-vec
    rtk
  ];

  postPatch = ''
    substituteInPlace headroom/install/runtime.py \
      --replace-fail 'sys.executable, "-m", "headroom.cli"' '"headroom"'
    substituteInPlace headroom/cli/wrap.py \
      --replace-fail 'sys.executable, "-m", "headroom.cli", "proxy"' '"headroom", "proxy"'
    # substituteInPlace headroom/cli/wrap.py \
    #   --replace-fail \
    #     'f'"'"'env_key = "OPENAI_API_KEY"\n'"'"''' \
    #     '""'
  '';

  doCheck = false;

  meta = {
    description = "context optimization layer for llm applications";
    homepage = "https://github.com/chopratejas/headroom";
    license = lib.licenses.asl20;
    mainProgram = "headroom";
  };
}
) { inherit ast-grep; onnxruntimeBin = onnxruntime; }