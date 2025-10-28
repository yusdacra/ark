{ pkgs, ... }:
{
  services.monado = {
    enable = true;
    defaultRuntime = false;
  };

  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    autoStart = true;
  };

  # programs.envision.enable = true;

  environment.systemPackages = [ pkgs.wlx-overlay-s ];
}
