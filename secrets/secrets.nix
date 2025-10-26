let
  yusdacra = builtins.readFile ./yusdacra.key.pub;
  wolumonde = builtins.readFile ./wolumonde.key.pub;
  dzwonek = builtins.readFile ./dzwonek.key.pub;
  develMobi = builtins.readFile ./develMobi.key.pub;
in
{
  "nixGithubAccessToken.age".publicKeys = [ yusdacra ];
  "websiteConfig.age".publicKeys = [
    yusdacra
    wolumonde
  ];
  "pdsConfig.age".publicKeys = [
    yusdacra
    wolumonde
  ];
  "clickeeProxyConfig.age".publicKeys = [
    yusdacra
    wolumonde
  ];
  "deployWebhook.age".publicKeys = [ yusdacra ];
  "persesSecret.age".publicKeys = [
    yusdacra
    wolumonde
  ];
  "headscaleOidcSecret.age".publicKeys = [
    yusdacra
    dzwonek
  ];
  "tailscaleAuthKey.age".publicKeys = [
    yusdacra
    wolumonde
  ];
  "develMobiTailscaleAuthKey.age".publicKeys = [
    yusdacra
    develMobi
  ];
}
