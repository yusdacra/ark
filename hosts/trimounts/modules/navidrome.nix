{config, pkgs, ...}: {
  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/music";
      Port = 9999;
      Address = "0.0.0.0";
      ListenBrainz = {
        Enabled = true;
        BaseURL = "https://piper.kittysay.xyz/1";
      };
    };
  };
}
