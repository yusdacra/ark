{
  pkgs,
  terra,
  inputs,
  lib,
  ...
}:
let
  pkg = pkgs.discord.override {
    withMoonlight = true;
    inherit (terra) moonlight;
    withOpenASAR = true;
    withTTS = false;
  };
in
{
  # imports = ["${inputs.moonlight}/nix/home-manager.nix"];

  home.packages = [
    (pkgs.symlinkJoin {
      name = "discord";
      paths = [ pkg ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/discord \
          --add-flags "--proxy-server=socks5://127.0.0.1:1337"
        wrapProgram $out/bin/Discord \
          --add-flags "--proxy-server=socks5://127.0.0.1:1337"
      '';
    })
  ];

  systemd.user.services.discord-socks-proxy = {
    Unit = {
      Description = "SSH SOCKS5 proxy for Discord";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.openssh}/bin/ssh -N -D 127.0.0.1:1337 root@wolumonde";
      Restart = "on-failure";
      RestartSec = "3s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
