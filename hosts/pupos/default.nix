{ inputs, tlib, ... }:
{
  imports = [
    "${inputs.home}/nixos"
    ../../modules
    ./hardware-configuration.nix
    ./modules/cliproxy.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  time.timeZone = "UTC";

  users.users.dawn = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHzGssWmVUOzJ9NyBPkcNfXk/cMAGYyDGDdYyAydN8dNAAAABHNzaDo="
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.tailscale = {
    enable = true;
    authKeyFile = "/etc/tailscale/authkey";
    extraUpFlags = [
      "--login-server=https://headscale.nekomimi.pet"
      "--accept-routes"
      "--accept-dns"
    ];
  };

  home-manager.users.dawn = {
    imports = [ ../../users/modules/tailscale ];
    services.tailscale.ours = {
      enable = true;
      controlServer = "https://headscale.nekomimi.pet";
      authKeyFile = "/home/dawn/.config/tailscale/ours-authkey";
      port = 1059;
    };
  };

  environment.systemPackages = [ ];
  system.stateVersion = "25.11";
}
