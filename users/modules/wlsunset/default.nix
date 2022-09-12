{inputs, ...}: let
  geo = import "${inputs.self}/locale/geo.nix";
in {
  services.wlsunset = {
    enable = true;
    latitude = geo.lat;
    longitude = geo.long;
  };
}
