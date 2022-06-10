{
  inputs,
  config,
  pkgs,
  lib,
  tlib,
  ...
}: let
  inherit (lib) fileContents mkIf;

  coreBin = v: "${pkgs.coreutils}/bin/${v}";
  nixBin = "${config.nix.package}/bin/nix";
  pkgBin = tlib.pkgBin pkgs;
in {
  imports = [
    ./nix.nix
    ./hm-system-defaults.nix
  ];

  console.font = "7x14";
  environment = {
    systemPackages = with pkgs; [
      binutils
      coreutils
      curl
      direnv
      dnsutils
      dosfstools
      fd
      bottom
      gptfdisk
      iputils
      jq
      manix
      moreutils
      nix-index
      nmap
      ripgrep
      skim
      tealdeer
      usbutils
      utillinux
      whois
      bat
      fzf
      exa
      lm_sensors
      mkpasswd
      zoxide
      bottom
      amber
      unzip
      unrar
      hydra-check
      du-dust
      mosh
      git
      git-crypt
    ];
    shellAliases = let
      ifSudo = string: mkIf config.security.sudo.enable string;
    in {
      g = pkgBin "git";
      git-optimize = "${pkgBin "git"} gc --aggressive --prune=now";
      cat = "${pkgBin "bat"} -pp --theme=base16";
      c = "cat";
      du = "${pkgs.du-dust}/bin/dust";
      df = "${coreBin "df"} -h";
      free = "${pkgs.procps}/bin/free -h";
      ls = pkgBin "exa";
      l = "${pkgBin "exa"} -lhg --git";
      la = "${pkgBin "exa"} -lhg --git -a";
      t = "${pkgBin "exa"} -lhg --git -T";
      ta = "${pkgBin "exa"} -lhg --git -a -T";
      n = nixBin;
      nf = "${nixBin} flake";
      nfu = "${nixBin} flake update";
      nfui = "${nixBin} flake lock --update-input";
      nfs = "${nixBin} flake show";
      nsh = "${nixBin} shell";
      nix-store-refs = "nix-store -qR";
      nosrs = ifSudo "sudo nixos-rebuild --fast switch";
      nosrb = ifSudo "sudo nixos-rebuild --fast boot";
      nosrt = ifSudo "sudo nixos-rebuild --fast test";
      ngc = ifSudo "sudo nix-collect-garbage";
      ngcdo = ifSudo "sudo nix-collect-garbage --delete-old";
      top = "${pkgs.bottom}/bin/btm";
      myip = "${pkgs.dnsutils}/bin/dig +short myip.opendns.com @208.67.222.222 2>&1";
      mn = let
        manix_preview = "manix '{}' | sed 's/type: /> type: /g' | bat -l Markdown --color=always --plain";
      in ''manix "" | rg '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | sk --preview="${manix_preview}" | xargs manix'';
      # systemd
      ctl = "systemctl";
      stl = ifSudo "s systemctl";
      utl = "systemctl --user";
      jtl = "journalctl";
    };
  };
  system.activationScripts.diff = ''
    if [ -z "$systemConfig" ]; then
      ${pkgs.nixUnstable}/bin/nix store \
      --experimental-features 'nix-command' \
      diff-closures /run/current-system "$systemConfig"
    fi
  '';
  users.mutableUsers = false;
  programs = {
    command-not-found.enable = true;
    git = {
      enable = true;
      config = {safe.directory = ["/etc/nixos"];};
    };
  };
  nixpkgs.config.allowUnfree = true;
}
