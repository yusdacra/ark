final: prev: {
  hydrus = prev.hydrus.overrideAttrs (old:
    let version = "436"; in
    {
      inherit version;

      src = prev.fetchFromGitHub {
        owner = "hydrusnetwork";
        repo = old.pname;
        rev = "v${version}";
        sha256 = "sha256-FXm8VUEY0OZ6/dc/qNwOXekhv5H2C9jjg/eNDoMvMn0=";
      };
    });
}
