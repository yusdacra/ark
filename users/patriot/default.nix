{ config, pkgs, ... }: {
  imports = [ ./home.nix ];

  users.users.patriot = {
    isNormalUser = true;
    createHome = true;
    home = "/home/patriot";
    extraGroups = [ "wheel" "adbusers" "dialout" ];
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

  security.pam.services.patriot = {
    enableGnomeKeyring = true;
    enableKwallet = false;
  };
  services = {
    gnome3 = {
      gnome-keyring.enable = true;
    };
    xserver = {
      enable = true;
      desktopManager = {
        plasma5.enable = true;
        gnome3.enable = false;
        xterm.enable = false;
      };
      displayManager = {
        autoLogin = {
          enable = true;
          user = "patriot";
        };
        lightdm.enable = false;
        gdm = {
          enable = false;
          wayland = true;
        };
        sddm.enable = true;
        startx.enable = false;
      };
    };
  };

  systemd.user.services.gnome-session-restart-dbus.serviceConfig = {
    Slice = "-.slice";
  };
  systemd = {
    targets = {
      network-online.enable = false;
    };
    services = {
      systemd-networkd-wait-online.enable = false;
      NetworkManager-wait-online.enable = false;
    };
  };
}
