final: prev: {
  abaddon = prev.abaddon.overrideAttrs (old: rec {
    version = "0.1.12";
    src = final.fetchFromGitHub {
      owner = "uowuo";
      repo = "abaddon";
      rev = "v${version}";
      sha256 = "sha256-Rz3c6RMZUiKQ0YKKQkCEkelfIGUq+xVmgNskj7uEjGI=";
      fetchSubmodules = true;
    };
    buildInputs =
      old.buildInputs
      ++ (with final; [
        miniaudio
        libsodium
        libopus
        spdlog
        pcre2
        rnnoise
        qrcodegen
        openssl
      ]);
  });
}
