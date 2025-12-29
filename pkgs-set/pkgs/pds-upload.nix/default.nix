{ lib
, stdenvNoCC
, makeWrapper
, nushell
, file
, secretsFile ? null
, ...
}:

stdenvNoCC.mkDerivation {
  pname = "pds-upload";
  version = "0.1.0";

  src = ./pds-upload.nu;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ nushell ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec
    
    install -Dm755 $src $out/libexec/pds-upload.nu

    makeWrapper ${nushell}/bin/nu $out/bin/pds-upload \
      --add-flags "$out/libexec/pds-upload.nu" \
      --prefix PATH : ${lib.makeBinPath [ file ]} \
      --run ${lib.escapeShellArg ''
        # Optional: Set secrets file from argument override
        ${lib.optionalString (secretsFile != null) ''
          export ATPROTO_SECRETS_FILE="${secretsFile}"
        ''}

        # Load secrets if the file exists (to populate ATPROTO_DID/PASSWORD)
        if [ -n "$ATPROTO_SECRETS_FILE" ] && [ -f "$ATPROTO_SECRETS_FILE" ]; then
          set -a
          source "$ATPROTO_SECRETS_FILE"
          set +a
        fi
      ''}

    runHook postInstall
  '';
}