{
  inputs,
  ...
}:
{
  imports = [
    (import inputs.stylix).homeModules.stylix
    ./stylix.conf.nix
  ];
}
