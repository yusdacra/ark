let
  yusdacra = builtins.readFile ./yusdacra.key.pub;
  wolumonde = builtins.readFile ./wolumonde.key.pub;
in {
  "wgWolumondeKey.age".publicKeys = [yusdacra wolumonde];
  "wgTkarontoKey.age".publicKeys = [yusdacra];
  "bernbotToken.age".publicKeys = [yusdacra wolumonde];
  "musikquadConfig.age".publicKeys = [yusdacra wolumonde];
  "nixGithubAccessToken.age".publicKeys = [yusdacra];
  "websiteConfig.age".publicKeys = [yusdacra wolumonde];
  "forgejoActRunnerToken.age".publicKeys = [yusdacra wolumonde];
  "xrayConfig.age".publicKeys = [yusdacra wolumonde];
  "pdsConfig.age".publicKeys = [yusdacra wolumonde];
}
