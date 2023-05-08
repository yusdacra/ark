{
  pkgs,
  inputs,
  ...
}: {
  services.nginx.virtualHosts."ms.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    root = "${inputs.musikspider.packages.${pkgs.system}.musikspider}";
  };
}
