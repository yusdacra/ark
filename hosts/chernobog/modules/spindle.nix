{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  spindleCfg = config.services.tangled.spindle;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [
    "${inputs.microvm-spindle}/nix/modules/spindle.nix"
  ];

  services.tangled.spindle = {
    enable = true;
    package = inputs.microvm-spindle.packages.${system}.spindle;
    server = {
      listenAddr = "0.0.0.0:7391";
      hostname = "ci.klbr.net";
      owner = "did:plc:dfl62fgb7wtjj3fcbb72naae";
      # secrets = {
      #   provider = "openbao";
      #   openbao.proxyAddr = "http://spindle.bao.lan.gaze.systems";
      # };
      secrets.provider = "sqlite";
    };
    pipelines = {
      workflowTimeout = "20m";
      microvm = {
        enableKVM = true;
        limits.total.memoryMiB = 6200;
      };
    };
    cache = {
      readUrls = ["https://cache.nixos.org"];
      trustedPublicKeys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
    };
  };
  systemd.tmpfiles.rules = [
"L+ /var/lib/spindle/images/nixos-x86_64 - - - - ${inputs.microvm-spindle.packages.${system}.spindle-nixos-image}"
"L+ /var/lib/spindle/images/alpine-x86_64 - - - - ${inputs.microvm-spindle.packages.${system}.spindle-alpine-image}"
    "L+ /var/lib/spindle/images/nixos - - - - /var/lib/spindle/images/nixos-x86_64"
    "L+ /var/lib/spindle/images/alpine - - - - /var/lib/spindle/images/alpine-x86_64"
  ];
  users.users.spindle = {
    group = "spindle";
    isSystemUser = true;
  };
  users.groups.spindle = { };
  users.groups.podman.members = [ "spindle" ];
  systemd.services.spindle = {
    # after = lib.mkForce [ "network.target" "openbao-proxy-spindle.service" ];
    serviceConfig = {
      User = "spindle";
      Group = "spindle";
    };
  };

  virtualisation.docker.enable = lib.mkForce false;
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };
}
