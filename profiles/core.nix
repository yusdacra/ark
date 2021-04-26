{ config, lib, pkgs, util, inputs, ... }:
let
  inherit (util) pkgBin;
  inherit (lib) fileContents mkIf;

in
{
  imports = [ ../local/locale.nix ];

  boot = {
    tmpOnTmpfs = true;
    loader.systemd-boot.configurationLimit = 10;
  };

  console.font = "7x14";

  environment =
    let
      coreBin = v: "${pkgs.coreutils}/bin/${v}";
      nixBin = "${config.nix.package}/bin/nix";
    in
    {
      systemPackages = with pkgs; [
        bat
        exa
        ripgrep
        curl
        jq
        git
        gptfdisk
        iputils
        lm_sensors
        mkpasswd
        ntfs3g
        zoxide
        bottom
        tealdeer
        amber
        unzip
        grit
        hydra-check
      ];

      shellAliases =
        let ifSudo = string: mkIf config.security.sudo.enable string;
        in
        {
          gtw = "${pkgBin "grit"} tree wnv";
          gtwa = "${pkgBin "grit"} add -p wnv";
          gt = pkgBin "grit";

          g = pkgBin "git";

          grep = "${pkgs.ripgrep}/bin/rg";
          cat = "${pkgBin "bat"} -pp --theme=base16";
          c = "${pkgBin "bat"} -pp --theme=base16";

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
          nfua = "${nixBin} flake update --recreate-lock-file";
          nfs = "${nixBin} flake show";
          np = "${nixBin} profile";
          npl = "${nixBin} profile info";
          npi = "${nixBin} profile install";
          npr = "${nixBin} profile remove";
          nsh = "${nixBin} shell";
          ndev = "${nixBin} develop";

          nosce = "cd /etc/nixos";
          nosr = ifSudo "sudo nixos-rebuild --fast";
          nosrs = ifSudo "sudo nixos-rebuild switch";
          nosrb = ifSudo "sudo nixos-rebuild boot";
          nosrt = ifSudo "sudo nixos-rebuild test";
          ncg = ifSudo "sudo nix-collect-garbage";
          ncgdo = ifSudo "sudo nix-collect-garbage --delete-old";

          top = "${pkgs.bottom}/bin/btm";

          myip =
            "${pkgs.dnsutils}/bin/dig +short myip.opendns.com @208.67.222.222 2>&1";

          sys-repl =
            "source /etc/set-environment && ${nixBin} repl ${./..}/repl.nix";
        };
    };

  nix =
    let
      flakes = lib.filterAttrs (name: value: value ? outputs) inputs;

      nixPath = lib.mapAttrsToList
        (name: _: "${name}=${inputs.${name}}")
        flakes;

      registry = builtins.mapAttrs
        (name: v: { flake = v; })
        flakes;
    in
    {
      package = pkgs.nixFlakes;
      autoOptimiseStore = true;
      optimise.automatic = true;
      allowedUsers = [ "@wheel" ];
      trustedUsers = [ "root" "@wheel" ];
      extraOptions = ''
        experimental-features = nix-command flakes ca-references
      '';
      nixPath = nixPath ++ [ "repl=${./..}/repl.nix" ];
      inherit registry;
    };

  # security = {
  #   hideProcessInformation = true;
  #   protectKernelImage = true;
  # };

  programs.command-not-found.enable = false;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  users.mutableUsers = false;
}
