let
  yusdacra = builtins.readFile ./yusdacra.key.pub;
  wolumonde = builtins.readFile ./wolumonde.key.pub;
  dzwonek = builtins.readFile ./dzwonek.key.pub;
  trimounts = builtins.readFile ./trimounts.key.pub;
  develMobi = builtins.readFile ./develMobi.key.pub;
in
{
  "nixGithubAccessToken.age".publicKeys = [ yusdacra ];
  "websiteConfig.age".publicKeys = [
    yusdacra
    wolumonde
    trimounts
  ];
  "pdsConfig.age".publicKeys = [
    yusdacra
    wolumonde
    trimounts
  ];
  "clickeeProxyConfig.age".publicKeys = [
    yusdacra
    wolumonde
    trimounts
  ];
  "persesSecret.age".publicKeys = [
    yusdacra
    wolumonde
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
    wolumonde
    trimounts
  ];
}
