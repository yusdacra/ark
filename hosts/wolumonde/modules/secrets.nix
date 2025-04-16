{lib, ...}: {
  age.secrets.bernbotToken.file = ../../../secrets/bernbotToken.age;
  age.secrets.wgWolumondeKey = {
    file = ../../../secrets/wgWolumondeKey.age;
    mode = "600";
    owner = "systemd-network";
    group = "systemd-network";
  };
  # age.secrets.musikquadConfig.file = ../../../secrets/musikquadConfig.age;
  # age.secrets.tmodloaderServerPass.file = ../../../secrets/tmodloaderServerPass.age;
  age.secrets.websiteConfig.file = ../../../secrets/websiteConfig.age;
  # age.secrets.giteaActRunnerToken.file = ../../../secrets/giteaActRunnerToken.age;
  # age.secrets.xrayConfig = {
  #   name = "xrayConfig.json";
  #   file = ../../../secrets/xrayConfig.age;
  #   mode = "600";
  #   # owner = "xray";
  #   # group = "xray";
  # };
  age.secrets.pdsConfig.file = ../../../secrets/pdsConfig.age;
}
