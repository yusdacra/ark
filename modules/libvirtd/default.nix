{config, ...}: {
  virtualisation.libvirtd.enable = true;
  environment.persistence."${config.system.persistDir}".directories = [
    "/var/lib/libvirt"
    "/var/lib/machines"
  ];
}
