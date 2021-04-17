{ pkgs, ... }: {
  imports = [ ./editor ];

  environment.systemPackages = with pkgs; [ git tokei ];

  documentation.dev.enable = true;
}
