let
  yusdacra = builtins.readFile ./yusdacra.key.pub;
  wolumonde = builtins.readFile ./wolumonde.key.pub;
in
{
  "wgProxyPrivateKey.age".publicKeys = [yusdacra wolumonde];
  "wgServerPrivateKey.age".publicKeys = [yusdacra];
  "bernbotToken.age".publicKeys = [yusdacra wolumonde];
  "nixGithubAccessToken.age".publicKeys = [yusdacra];
}
