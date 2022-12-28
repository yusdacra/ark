{pkgs, ...}: {
  virtualisation.libvirtd.enable = true;
  environment.systemPackages = [pkgs.gnome.gnome-boxes];
}
