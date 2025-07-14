{config, ...}: {
  age.secrets.netbirdClientKey = {
    file = ../../../secrets/netbirdClientKey.age;
    mode = "660";
    owner = "netbird-wt0";
    group = "netbird-wt0";
  };

  services.netbird.clients.wt0 = let
    mgmtUrl = {
      Scheme = "https";
      Host = "${config.services.netbird.server.domain}:443";
    };
  in {
    port = 51820;
    config = {
      ManagementURL = mgmtUrl;
      AdminURL = mgmtUrl;
    };
  };
  systemd.services.netbird-wt0.postStart = ''
    /run/current-system/sw/bin/netbird-wt0 login --setup-key-file ${config.age.secrets.netbirdClientKey.path}
  '';
  users.users.root.extraGroups = ["netbird-wt0"];
}
