{
  services.fail2ban.enable = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  networking.firewall.public."ssh".allowedTCPPorts = [ 22 ];
}
