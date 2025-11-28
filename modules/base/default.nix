{
  inputs,
  config,
  pkgs,
  lib,
  tlib,
  ...
}:
let
  inherit (lib) fileContents mkIf;

  coreBin = v: "${pkgs.coreutils}/bin/${v}";
  nixBin = "${config.nix.package}/bin/nix";
  pkgBin = tlib.pkgBin;
in
{
  imports = [
    ./nix.nix
    ./hm-system-defaults.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      binutils
      coreutils
      dnsutils
      moreutils
      iputils
      curl
      direnv
      fd
      nmap
      ripgrep
      tealdeer
      usbutils
      util-linux
      bottom
      unzip
      unrar
      git
    ];
    shellAliases =
      let
        ifSudo = string: mkIf config.security.sudo.enable string;
        inherit (pkgs) dust;
      in
      {
        g = pkgBin config.programs.git.package;
        du = "${pkgBin dust}";
        df = "${coreBin "df"} -h";
        free = "${pkgs.procps}/bin/free -h";
        n = nixBin;
        nb = "${nixBin} build";
        nf = "${nixBin} flake";
        nfu = "${nixBin} flake update";
        nfui = "${nixBin} flake update";
        nfs = "${nixBin} flake show";
        nsh = "${nixBin} shell";
        top = "${pkgs.bottom}/bin/btm";
        myip = "${pkgs.dnsutils}/bin/dig +short myip.opendns.com @208.67.222.222 2>&1";
        # systemd
        ctl = "systemctl";
        stl = ifSudo "s systemctl";
        utl = "systemctl --user";
        jtl = "journalctl";
      };
  };
  system.activationScripts.diff = ''
    if [ -z "$systemConfig" ]; then
      ${config.nix.package}/bin/nix store \
      --experimental-features 'nix-command' \
      diff-closures /run/current-system "$systemConfig"
    fi
  '';

  users.mutableUsers = false;

  programs.mosh = {
    enable = true;
    openFirewall = false;
  };
  programs.git.enable = true;
}
