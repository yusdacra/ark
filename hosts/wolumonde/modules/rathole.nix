{config, ...}:
let
  ratholePort = 11111;
  mcPort = 25565;
in
{
  age.secrets.ratholeCreds.file = ../../../secrets/ratholeCreds.age;
  services.rathole = {
    enable = true;
    role = "server";
    settings = {
      server = {
        bind_addr = "0.0.0.0:${toString ratholePort}";
        services.minecraft.bind_addr = "0.0.0.0:${toString mcPort}";
      };
    };
    credentialsFile = config.age.secrets.ratholeCreds.path;
  };
  networking.firewall = {
    allowedTCPPorts = [ratholePort mcPort];
    allowedUDPPorts = [ratholePort mcPort];
  };
}
