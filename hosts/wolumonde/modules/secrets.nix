{
  age.secrets.bernbotToken.file = ../../../secrets/bernbotToken.age;
  age.secrets.wgWolumondeKey = {
    file = ../../../secrets/wgWolumondeKey.age;
    mode = "600";
    owner = "systemd-network";
    group = "systemd-network";
  };
  age.secrets.musikquadConfig.file = ../../../secrets/musikquadConfig.age;
  age.secrets.tmodloaderServerPass.file = ../../../secrets/tmodloaderServerPass.age;
}
