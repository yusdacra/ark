let
  yusdacra = builtins.readFile ./yusdacra.key.pub;
  dzwonek = builtins.readFile ./dzwonek.key.pub;
  trimounts = builtins.readFile ./trimounts.key.pub;
  develMobi = builtins.readFile ./develMobi.key.pub;
in
{
  "nixGithubAccessToken.age".publicKeys = [ yusdacra ];
  "websiteConfig.age".publicKeys = [
    yusdacra
    trimounts
  ];
  "pdsConfig.age".publicKeys = [
    yusdacra
    trimounts
  ];
  "clickeeProxyConfig.age".publicKeys = [
    yusdacra
    trimounts
  ];
  "persesSecret.age".publicKeys = [
    yusdacra
    trimounts
  ];
  "headscaleOidcSecret.age".publicKeys = [
    yusdacra
    dzwonek
  ];
  "develMobiTailscaleAuthKey.age".publicKeys = [
    yusdacra
    develMobi
  ];
  "cloudflareDnsEdit.age".publicKeys = [
    yusdacra
    dzwonek
    trimounts
  ];
  "bunnyApiKey.age".publicKeys = [
    yusdacra
    dzwonek
    trimounts
  ];
}
