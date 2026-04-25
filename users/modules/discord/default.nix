{
  pkgs,
  terra,
  ...
}:
let
  pkg = pkgs.discord.override {
    withMoonlight = false;
    inherit (terra) moonlight;
    withOpenASAR = false;
    withTTS = false;
  };
in
{
  imports = [./service.nix];

  home.packages = [
    (pkgs.symlinkJoin {
      name = "discord";
      paths = [ pkg ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/discord \
          --add-flags "--proxy-server=socks5://127.0.0.1:1338"
        wrapProgram $out/bin/Discord \
          --add-flags "--proxy-server=socks5://127.0.0.1:1338"
      '';
    })
  ];
}
