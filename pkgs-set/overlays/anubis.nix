final: prev: {
  anubis =
    let
      pname = "anubis";
      version = "1.17.0";

      src = final.fetchFromGitHub {
        owner = "TecharoHQ";
        repo = "anubis";
        tag = "v${version}";
        hash = "sha256-pwTb1P5gCxdiXylRo7jhykbJkJA4l3hE+imN9A2EF7g=";
      };
    in
    prev.anubis.overrideAttrs (old: {
      inherit src version;
      name = "${pname}-${version}";
      vendorHash = "sha256-v9GsTUzBYfjh6/ETBbFpN5dqMzMaOz8w39Xz1omaPJE=";
    });
}
