final: prev: {
  kakoune-unwrapped = prev.kakoune-unwrapped.overrideAttrs (old: rec {
    version = "958a9431214dc4bece30aa30a8159e0bb8b5bbe7";
    src = prev.fetchFromGitHub {
      owner = "mawww";
      repo = "kakoune";
      rev = version;
      sha256 = "sha256-KSFuM9WQxdUc7lFaDYGB9zZGOHuckto9SEd9cR7evKo=";
    };
  });
}
