final: prev: {
  kak-lsp = prev.kak-lsp.overrideAttrs (old: rec {
    version = "0aaff957839ab24f5b33f9e58ebe0903073573b0";
    src = prev.fetchFromGitHub rec {
      owner = "kak-lsp";
      repo = owner;
      rev = version;
      sha256 = "0nka51szivwhlfkimjiyzj67nxh75m784c28ass6ihlfax631w9m";
    };

    cargoSha256 = "174qy50m9487vv151vm8q6sby79dq3gbqjbz6h4326jwsc9wwi8c";
  });
}
