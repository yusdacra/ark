{
  pkgs,
  terra,
  ...
}:
let
  # pkg = pkgs.discord.override {
  #   withMoonlight = true;
  #   inherit (terra) moonlight;
  #   withOpenASAR = false;
  #   withTTS = false;
  # };
  pkg = pkgs.equibop;
in
{
  imports = [./service.nix];

  home.packages = [
    (pkgs.symlinkJoin {
      name = "equibop";
      paths = [ pkg ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/equibop \
          --add-flags "--proxy-server=socks5://127.0.0.1:1338"
      '';
    })
  ];
}
