{config, ...}: {
  imports = [../dns ../iwd];
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
  };
  environment.persistence."${config.system.persistDir}" = {
    directories = ["/etc/NetworkManager/system-connections"];
  };
}
