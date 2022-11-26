{
  config,
  inputs,
  tlib,
  ...
}: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.sharedModules = [
    "${inputs.self}/users/modules/settings"
    {
      home = {
        inherit (config.environment) shellAliases sessionVariables;
        stateVersion = config.system.stateVersion;
      };
      xdg.configFile."nix/registry.json".text = config.environment.etc."nix/registry.json".text;
      xdg.configFile."nix/nix.conf".source = config.environment.etc."nix/nix.conf".source;
      # xdg.configFile."nix/netrc".source = config.environment.etc."nix/netrc".source;
    }
    ({
      config,
      pkgs,
      lib,
      ...
    }: {
      home.packages = [
        (
          pkgs.writeShellScriptBin "apply-hm-env" ''
            ${lib.optionalString (config.home.sessionPath != []) ''
              export PATH=${builtins.concatStringsSep ":" config.home.sessionPath}:$PATH
            ''}
            ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (k: v: ''
                export ${k}="${v}"
              '')
              config.home.sessionVariables)}
            ${config.home.sessionVariablesExtra}
            exec "$@"
          ''
        )
      ];
    })
  ];
  home-manager.extraSpecialArgs = {
    inherit inputs tlib;
    nixosConfig = config;
  };
}
