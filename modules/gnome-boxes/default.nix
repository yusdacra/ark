{pkgs, ...}: {
  imports = [../libvirtd];
  environment.systemPackages = [pkgs.gnome.gnome-boxes];
}
