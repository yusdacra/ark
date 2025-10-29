{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_cachyos-lto;
}
