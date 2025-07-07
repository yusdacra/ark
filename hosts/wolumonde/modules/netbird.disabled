{ config, ... }:
let
  oidcUrl = config.services.pocket-id.settings.APP_URL;
  oidcClientId = "41f4ea08-a20f-43dc-aa75-c76efa49bbb8";
in
{
  age.secrets.netbirdTurnSecret = {
    file = ../../../secrets/netbirdTurnSecret.age;
  };
  age.secrets.netbirdDataStoreEncKey.file = ../../../secrets/netbirdDataStoreEncKey.age;
  age.secrets.netbirdCoturnPass = {
    file = ../../../secrets/netbirdCoturnPass.age;
    mode = "660";
    owner = "turnserver";
    group = "turnserver";
  };

  services.netbird.server = {
    enable = true;
    enableNginx = true;
    domain = "bird.gaze.systems";
    dashboard.settings = {
      AUTH_AUTHORITY = oidcUrl;
      AUTH_CLIENT_ID = oidcClientId;
      AUTH_AUDIENCE = oidcClientId;
    };
    management = {
      metricsPort = 9409;
      oidcConfigEndpoint = "${oidcUrl}/.well-known/openid-configuration";
      turnDomain = config.services.netbird.server.domain;
      settings = {
        TURNConfig.Secret._secret = config.age.secrets.netbirdTurnSecret.path;
        DataStoreEncryptionKey._secret = config.age.secrets.netbirdDataStoreEncKey.path;
        HttpConfig = {
          AuthAudience = oidcClientId;
          AuthIssuer = oidcUrl;
        };
        PKCEAuthorizationFlow.ProviderConfig = {
          ClientID = oidcClientId;
          Audience = oidcClientId;
          TokenEndpoint = "${oidcUrl}/api/oidc/token";
          AuthorizationEndpoint = "${oidcUrl}/authorize";
          UseIDToken = true;
        };
      };
    };
    coturn = {
      enable = true;
      passwordFile = config.age.secrets.netbirdCoturnPass.path;
      useAcmeCertificates = true;
    };
  };

  services.nginx.virtualHosts.${config.services.netbird.server.domain} = {
    useACMEHost = "gaze.systems";
    forceSSL = true;
    quic = true;
    kTLS = true;
  };
}
