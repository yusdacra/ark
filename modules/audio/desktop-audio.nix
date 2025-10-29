{
  services.pipewire.extraConfig.pipewire = {
    "10-virtual-sink" = {
      "context.objects" = [
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "virtual_sink";
            "node.description" = "Virtual Sink for Recording";
            "media.class" = "Audio/Sink";
            "audio.position" = "FL,FR";
          };
        }
      ];
    };
  };
}
