{
  services.stubby = {
    roundRobinUpstreams = false;
    upstreamServers = let
      nextDnsId = "75e43d";
    in ''
      - address_data: 45.90.28.0
        tls_auth_name: "${nextDnsId}.dns1.nextdns.io"
      - address_data: 2a07:a8c0::0
        tls_auth_name: "${nextDnsId}.dns1.nextdns.io"
      - address_data: 45.90.30.0
        tls_auth_name: "${nextDnsId}.dns2.nextdns.io"
      - address_data: 2a07:a8c1::0
        tls_auth_name: "${nextDnsId}.dns2.nextdns.io"
    '';
  };
}
