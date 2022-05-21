{
  imports = [./dns];
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  networking.dhcpcd.extraConfig = ''
    noarp
    nodelay
  '';
  # https://github.com/NixOS/nixpkgs/issues/60900
  # systemd.services.systemd-user-sessions.enable = false;
}
