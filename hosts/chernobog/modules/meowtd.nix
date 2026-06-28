{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    attrNames
    concatStringsSep
    escapeShellArg
    mapAttrs
    mapAttrsToList
    ;

  receivePackage = inputs.meowtd.packages.${pkgs.stdenv.hostPlatform.system}.meowtd-receive;

  localKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUIHFy8lBU8Iy5253Lglw0v67k9ozxjLWprjTjwTsrm dawn@chernobog";

  motds = {
    motd-ana = {
      label = "ana";
      file = "/var/lib/meowtd/ana";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGI8jgqru/3LFgk12C9Zc/NL5di5+jGocQZi/dA73ZRr regent@astaroth.dns.sharkgirl.pet"
        localKey
      ];
    };

    motd-niri = {
      label = "niri";
      file = "/var/lib/meowtd/niri";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ7Y9Je7H3gC72cgdEH4wifUDsmhKMeU5Z4oL1s1WcSE niri@nekomimi.pet"
        localKey
      ];
    };
  };

  receiveCommand =
    file:
    concatStringsSep " " [
      "MEOWTD_PATH=${escapeShellArg file}"
      "MEOWTD_MAX_LENGTH=1024"
      "exec ${receivePackage}/bin/meowtd-receive"
    ];

  forcedKey = file: key: ''
    command="${receiveCommand file}",restrict ${key}
  '';
in
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      AllowUsers = attrNames motds;
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users = {
    groups = mapAttrs (_: _: { }) motds;
    users = mapAttrs (name: motd: {
      group = name;
      isSystemUser = true;
      shell = pkgs.runtimeShell;
      openssh.authorizedKeys.keys = map (forcedKey motd.file) motd.authorizedKeys;
    }) motds;
  };

  systemd.tmpfiles.rules =
    [ "d /var/lib/meowtd 0755 root root -" ]
    ++ mapAttrsToList (name: motd: "f ${motd.file} 0664 root ${name} -") motds;

  home-manager.users.mayer.programs.nushell.extraConfig = lib.mkAfter ''
    let motds = [
      { label: "my owner <3", path: "/var/lib/meowtd/ana" }
      { label: "niri", path: "/var/lib/meowtd/niri" }
    ]

    for motd_entry in $motds {
      if (not ($motd_entry.path | path exists)) {
        continue
      }

      let motd = (open --raw $motd_entry.path | str trim)
      if (not ($motd | str trim | is-empty)) {
        print $"(ansi default_dimmed)($motd_entry.label): ($motd)(ansi reset)"
      }
    }
  '';
}
