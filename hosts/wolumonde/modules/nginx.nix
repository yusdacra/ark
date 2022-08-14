{inputs, ...}: {
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = (import "${inputs.self}/personal.nix").emails.primary;
  };
}
