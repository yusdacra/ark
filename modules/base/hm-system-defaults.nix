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
  ];
  home-manager.extraSpecialArgs = {inherit inputs tlib;};
}
