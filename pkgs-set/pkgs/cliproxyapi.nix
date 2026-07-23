{
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  ...
}:

stdenvNoCC.mkDerivation {
  pname = "cliproxyapi";
  version = "7.2.97";

  src = fetchurl {
    url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v7.2.97/CLIProxyAPI_7.2.97_linux_amd64.tar.gz";
    hash = "sha256-nefXh2m9WqKJAe8YdmxlxB/bdQJYpbMYES3gKSgBbtQ=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  dontUnpack = true;

  installPhase = ''
    tar -xzf "$src"
    install -Dm755 cli-proxy-api $out/bin/cli-proxy-api
    install -Dm644 LICENSE $out/share/licenses/cliproxyapi/LICENSE
  '';
}
