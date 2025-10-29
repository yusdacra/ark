{ ... }:
{
  stylix.targets.mako.enable = true;
  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      border-radius = 2;
      default-timeout = 4000;
    };
  };
}
