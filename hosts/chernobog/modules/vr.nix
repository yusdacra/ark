{ pkgs, ... }:
{
  services.monado = {
    enable = true;
    defaultRuntime = false;
  };

  services.wivrn = {
    enable = true;
    openFirewall = true;
    # defaultRuntime = true;
    autoStart = true;
    highPriority = true;
    config = {
      enable = true;
      json = {
        encoder =
          {
            encoder = "vaapi";
            codec = "h265";
          }
        ;
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
