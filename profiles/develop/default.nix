{ pkgs, ... }: {
  imports = [ ./editor ];

  environment.systemPackages = with pkgs; [ git gcc tokei gnumake ];

  documentation.dev.enable = true;
}
