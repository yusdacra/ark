{
  pkgs,
  config,
  ...
}: {
  programs.mako = {
    enable = true;
    anchor = "top-center";
    font = config.settings.font.fullName;
    borderRadius = 16;
    extraConfig = builtins.readFile (
      builtins.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/mako/d077d9832e8f22777a4812eadbfb658e793cbdfc/config";
        sha256 = "sha256:1c8j16ljbnynb5kplxvhg99rw536hbxxz1rl8qgaixdf2bg2awp0";
      }
    );
  };
}
