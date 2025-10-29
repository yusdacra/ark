{ pkgs, ... }:
let
  rate = 48000;
  quant = 256;
  quantRateMax = "${toString quant}/${toString rate}";
  quantRateMin = "${toString (quant / 2)}/${toString rate}";
in
{
  imports = [ ../../../modules/audio/desktop-audio.nix ];

  environment.systemPackages = with pkgs; [
    helvum
    pwvucontrol
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    "context.properties" = {
      "default.clock.rate" = rate;
      "default.clock.quantum" = quant;
      "default.clock.min-quantum" = quant / 2;
      "default.clock.max-quantum" = quant;
    };
  };

  services.pipewire.extraConfig.pipewire-pulse."92-low-latency" = {
    context.modules = [
      {
        name = "libpipewire-module-protocol-pulse";
        args = {
          pulse.min.req = quantRateMin;
          pulse.default.req = quantRateMax;
          pulse.max.req = quantRateMax;
          pulse.min.quantum = quantRateMin;
          pulse.max.quantum = quantRateMax;
        };
      }
    ];
    stream.properties = {
      node.latency = quantRateMax;
      resample.quality = 1;
    };
  };
}
