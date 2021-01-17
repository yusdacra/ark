{ config, pkgs, ... }: {
  imports = [ ./home.nix ];

  users.users.patriot = {
    isNormalUser = true;
    createHome = true;
    home = "/home/patriot";
    extraGroups = [ "wheel" "adbusers" "dialout" "docker" ];
    shell = pkgs.zsh;
    hashedPassword =
      "$6$spzqhAyJfhHy$iHgLBlhjGn1l8PnbjJdWTn1GPvcjMqYNKUzdCe/7IrX6sHNgETSr/Nfpdmq9FCXLhrAfwHOd/q/8SvfeIeNX4/";
  };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  programs = {
    adb.enable = true;
    steam.enable = true;
    java = {
      enable = true;
      package = pkgs.jre8;
    };
  };

  security.pam.services.patriot.enableGnomeKeyring = true;
  services = {
    gnome3 = {
      gnome-keyring.enable = true;
    };
    xserver = {
      enable = true;
      desktopManager.gnome3.enable = true;
      displayManager.gdm.enable = true;
    };
  };
}
