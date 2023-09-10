{config, ...}: {
  services.couchdb = {
    enable = true;
    port = 5999;
    configFile = "/var/lib/couchdb/config";
  };
  services.nginx.virtualHosts."couchdb.gaze.systems" = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:${toString config.services.couchdb.port}";
    # locations."/".extraConfig = ''
    #   add_header 'Access-Control-Allow-Credentials' 'true';
    #   add_header 'Access-Control-Allow-Methods' 'GET, PUT, POST, HEAD, DELETE';
    #   add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Content-Type,Origin,Referer';
    #   add_header 'Access-Control-Max-Age' 3600;
    # '';
  };
}