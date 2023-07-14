{config, ...}: {
  virtualisation.waydroid.enable = true;
  environment.persistence."${config.system.persistDir}" = {
    directories = ["/var/lib/waydroid"];
  };
}
