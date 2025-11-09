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
    config = {
      enable = true;
      json = {
        scale = 1.0;
        bitrate = 60000000;
        encoders = [
          {
            encoder = "vaapi";
            codec = "h265";
          }
        ];
      };
    };
  };

  # programs.envision.enable = true;

  environment.systemPackages = with pkgs; [ wlx-overlay-s eepyxr wayvr-dashboard ];
}
