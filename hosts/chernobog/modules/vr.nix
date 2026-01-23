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

  environment.systemPackages = with pkgs; [ eepyxr wayvr xrizer ];

  home-manager.sharedModules = [{
    xdg.configFile."openvr/openvrpaths.vrpath".text = ''
      {
        "config" :
        [
          "/home/mayer/.local/share/Steam/config"
        ],
        "external_drivers" : null,
        "jsonid" : "vrpathreg",
        "log" :
        [
          "/home/mayer/.local/share/Steam/logs"
        ],
        "runtime" :
        [
          "${pkgs.xrizer}/lib/xrizer"
        ],
        "version" : 1
      }
    '';
  }];
}
