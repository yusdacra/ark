{ pkgs, ... }:
{
  security.acme.certs."ptr.pet".extraDomainNames = [
    "mta-sts.ptr.pet"
    "autoconfig.ptr.pet"
    "autodiscover.ptr.pet"
  ];
  services.nginx.virtualHosts."ptr.pet" = {
    useACMEHost = "ptr.pet";
    quic = true;
    kTLS = true;
    forceSSL = true;
    locations."/mail/config-v1.1.xml" = {
      return = "301 https://autoconfig.migadu.com/mail/config-v1.1.xml";
    };
    locations."/Autodiscover/Autodiscover.xml" = {
      return = "301 https://autodiscover.migadu.com/Autodiscover/Autodiscover.xml";
    };
  };
  services.nginx.virtualHosts."mta-sts.ptr.pet" =
    let
      file = pkgs.writeText "mta-sts.txt" ''
        version: STSv1
        mode: enforce
        mx: aspmx1.migadu.com
        mx: aspmx2.migadu.com
        max_age: 31557600
      '';
    in
    {
      useACMEHost = "ptr.pet";
      quic = true;
      kTLS = true;
      forceSSL = true;
      locations."=/.well-known/mta-sts.txt".extraConfig = ''
        alias ${file};
        default_type text/plain;
      '';
    };
  services.nginx.virtualHosts."autoconfig.ptr.pet" = {
    useACMEHost = "ptr.pet";
    quic = true;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      return = "301 https://autoconfig.migadu.com$request_uri";
    };
  };
  services.nginx.virtualHosts."autodiscover.ptr.pet" = {
    useACMEHost = "ptr.pet";
    quic = true;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      return = "301 https://autodiscover.migadu.com$request_uri";
    };
  };
}
