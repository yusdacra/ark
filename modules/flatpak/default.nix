{config, ...}: {
  services.flatpak.enable = true;
  environment.persistence."${config.system.persistDir}".directories = [
    "/var/lib/flatpak"
  ];
}
