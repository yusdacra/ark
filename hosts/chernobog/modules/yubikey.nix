{ pkgs, ... }:

{
  services.pcscd.enable = true;

  services.udev.packages = with pkgs; [
    libfido2
    yubikey-personalization
  ];

  environment.systemPackages = with pkgs; [
    yubikey-manager
    libfido2
    pam_u2f
  ];
}