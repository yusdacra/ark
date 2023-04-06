{
  pkgs,
  inputs,
  ...
}: {
  services.nginx.virtualHosts."gaze.systems" = {
    enableACME = true;
    forceSSL = true;
    root = "${inputs.blog.packages.${pkgs.system}.site}";
    locations."/".extraConfig = ''
      add_header cache-control max-age=1800;
    '';
  };
}
