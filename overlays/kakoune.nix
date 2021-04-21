final: prev: {
  kakoune-unwrapped = prev.kakoune-unwrapped.overrideAttrs (old: {
    version = "5696ed02";
    src = builtins.fetchGit {
      url = "https://github.com/mawww/kakoune.git";
      rev = "5696ed02e49cb9ba076a9a8ce908597720e7df1c";
    };
  });
}
