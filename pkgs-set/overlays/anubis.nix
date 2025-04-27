final: prev: {
  anubis =
    let
      pname = "anubis";
      version = "1.17.0-beta4";

      src = final.fetchFromGitHub {
        owner = "TecharoHQ";
        repo = "anubis";
        tag = "v${version}";
        hash = "sha256-UP6zWaosz8t43K1AgNH0e3QOCVNfX+kka2CfgVfbPvA=";
      };

      anubisXess = final.buildNpmPackage {
        inherit src version;
        pname = "${pname}-xess";

        npmDepsHash = "sha256-QrW0grgNRZRum2mCec86Za1UV4R5QSRlhjVYFsZDwY8=";

        buildPhase = ''
          runHook preBuild
          npx postcss ./xess/xess.css -o xess.min.css
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp xess.min.css $out
          runHook postInstall
        '';
      };
    in
    prev.anubis.overrideAttrs (old: {
      inherit src version;
      name = "${pname}-${version}";
      vendorHash = "sha256-ro1Ym0RxstnzkRvxfAM5ya4KoAdw+vQggFNSyqr+dnw=";
    });
}
