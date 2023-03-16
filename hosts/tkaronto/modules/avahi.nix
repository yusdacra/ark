{
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      workstation = true;
      userServices = true;
      domain = true;
      hinfo = true;
    };
    openFirewall = true;
  };
}
