{config, ...}: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.sharedModules = [
    {
      home.sessionVariables = {inherit (config.environment.sessionVariables) NIX_PATH;};
      xdg.configFile."nix/registry.json".text = config.environment.etc."nix/registry.json".text;
      xdg.configFile."nix/nix.conf".source = config.environment.etc."nix/nix.conf".source;
    }
  ];
}
