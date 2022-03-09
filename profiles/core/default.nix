{
  self,
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) fileContents mkIf;
  pkgBin = lib.our.pkgBinNoDep pkgs;
  coreBin = v: "${pkgs.coreutils}/bin/${v}";
  nixBin = "${config.nix.package}/bin/nix";
in {
  imports = [../cachix ../../locale ../../secrets/secrets.nix];
  boot = {
    tmpOnTmpfs = true;
    loader.systemd-boot.configurationLimit = 10;
  };
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
      git
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
      git
      lm_sensors
      mkpasswd
      ntfs3g
      zoxide
      bottom
      amber
      unzip
      unrar
      grit
      hydra-check
      nix-index
      du-dust
      mosh
      (
        pkgs.runCommand
        "0x0.sh"
        {}
        ''
          mkdir -p $out/bin
          cp ${
            pkgs.fetchurl
            {
              url = "https://raw.githubusercontent.com/Calinou/0x0/master/bin/0x0";
              sha256 = "sha256-Fad+AKBuA49qtRQfnroqjaNWeuRaCekXZG9sS9JVeaM=";
            }
          } $out/bin/0x0
          chmod +x $out/bin/0x0
        ''
      )
    ];
    shellAliases = let
      ifSudo = string: mkIf config.security.sudo.enable string;
    in {
      gtw = "${pkgBin "grit"} tree wnv";
      gtwa = "${pkgBin "grit"} add -p wnv";
      gt = pkgBin "grit";
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
      nfc = "${nixBin} flake check";
      nfu = "${nixBin} flake update";
      nfui = "${nixBin} flake lock --update-input";
      nfs = "${nixBin} flake show";
      np = "${nixBin} profile";
      nb = "${nixBin} build";
      npl = "${nixBin} profile info";
      npi = "${nixBin} profile install";
      npr = "${nixBin} profile remove";
      nsh = "${nixBin} shell";
      nsr = "${nixBin} search";
      nsrp = "${nixBin} search nixpkgs";
      ndev = "${nixBin} develop";
      nrun = "${nixBin} run";
      nrefs = "nix-store -qR";
      noscd = "cd /etc/nixos";
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
      # fix nixos-option
      nixos-option = "nixos-option -I nixpkgs=${self}/lib/compat";
      # sudo
      s = ifSudo "sudo -E";
      si = ifSudo "sudo -i";
      se = ifSudo "sudoedit";
      # systemd
      ctl = "systemctl";
      stl = ifSudo "s systemctl";
      utl = "systemctl --user";
      ut = "systemctl --user start";
      un = "systemctl --user stop";
      up = ifSudo "s systemctl start";
      dn = ifSudo "s systemctl stop";
      jtl = "journalctl";
    };
  };
  system.activationScripts.diff = ''
    ${pkgs.nixUnstable}/bin/nix store \
    --experimental-features 'nix-command' \
    diff-closures /run/current-system "$systemConfig"
  '';
  nix = let
    registry =
      builtins.removeAttrs
      (builtins.mapAttrs (_: v: {flake = v;}) (lib.filterAttrs (_: v: v ? outputs) inputs))
      ["bud"];
  in {
    package = pkgs.nixUnstable;
    gc.automatic = true;
    optimise.automatic = true;
    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';
    inherit registry;
    settings = {
      sandbox = true;
      allowed-users = ["@wheel"];
      trusted-users = ["root" "@wheel"];
      auto-optimise-store = true;
    };
  };
  programs.command-not-found.enable = false;
  home-manager.useGlobalPkgs = true;
  users.mutableUsers = false;
  # For rage encryption, all hosts need a ssh key pair
  /*
   services.openssh = {
   enable = true;
   openFirewall = lib.mkDefault false;
   };
   */
  services.earlyoom.enable = true;
}
