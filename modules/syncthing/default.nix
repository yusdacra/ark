{config, inputs, ...}: {
  users.users.syncthing.extraGroups = ["users"];
  services.syncthing = {
    enable = true;
    devices.redmi-phone = {
      id = builtins.readFile "${inputs.self}/secrets/redmi-phone.syncthing.id";
      introducer = true;
      autoAcceptFolders = true;
    };
    dataDir = "${config.system.persistDir}/syncthing";
  };
}
