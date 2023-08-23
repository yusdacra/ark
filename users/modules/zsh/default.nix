{
  config,
  tlib,
  lib,
  pkgs,
  ...
}: let
  pkgBin = tlib.pkgBin;
in {
  programs.zsh = {
    enable = true;
    autocd = true;
    enableVteIntegration = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    plugins = [
      {
        name = "per-directory-history";
        src = pkgs.fetchFromGitHub {
          owner = "jimhester";
          repo = "per-directory-history";
          rev = "d2e291dd6434e340d9be0e15e1f5b94f32771c06";
          hash = "sha256-VHRgrVCqzILqOes8VXGjSgLek38BFs9eijmp0JHtD5Q=";
        };
      }
    ];
    # configure history
    history = {
      extended = true;
      ignorePatterns = ["rm *" "mv *" "l" "ls" "ll" "g s" "git status"];
      save = 1000000;
      size = 1000000;
    };
    # xdg compliant
    dotDir = ".config/zsh";
    history.path = "${config.home.homeDirectory}/.local/share/zsh/history";
    # extra stuff for fixing gpg-agent ssh and some random commands
    initExtra = ''
      ${
        lib.optionalString
        (config.programs.ssh.enable && config.services.gpg-agent.enable)
        "export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)"
      }

      function tomp4 () {
        ${pkgBin pkgs.ffmpeg} -i $1 -c:v libx264 -preset slow -crf 30 -c:a aac -b:a 128k "$1.mp4"
      }

      function topng () {
        ${pkgBin pkgs.ffmpeg} -i $1 "$1.png"
      }

      # fix some key stuff
      bindkey "$terminfo[kRIT5]" forward-word
      bindkey "$terminfo[kLFT5]" backward-word

      # makes completions pog
      zstyle ':completion:*' menu select

      # which env we are in
      ${pkgBin pkgs.any-nix-shell} zsh --info-right | source /dev/stdin
    '';
  };
}
