{
  fetchurl,
  runCommand,
  ...
}: let
  ttf = fetchurl {
    url = "https://dtinth.github.io/comic-mono-font/ComicMono.ttf";
    sha256 = "sha256-O8FCXpIqFqvw7HZ+/+TQJoQ5tMDc6YQy4H0V9drVcZY=";
  };
in
  runCommand "comic-mono" {} ''
    mkdir -p $out/share/fonts/truetype
    ln -s ${ttf} $out/share/fonts/truetype
  ''
