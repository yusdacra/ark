let
  yusdacra = builtins.readFile ./yusdacra.key.pub;
  wolumonde = builtins.readFile ./wolumonde.key.pub;
in {
  "bernbotToken.age".publicKeys = [yusdacra wolumonde];
  "musikquadConfig.age".publicKeys = [yusdacra wolumonde];
  "nixGithubAccessToken.age".publicKeys = [yusdacra];
  "websiteConfig.age".publicKeys = [yusdacra wolumonde];
  "forgejoActRunnerToken.age".publicKeys = [yusdacra wolumonde];
  "xrayConfig.age".publicKeys = [yusdacra wolumonde];
  "pdsConfig.age".publicKeys = [yusdacra wolumonde];
  "webhookAuth.age".publicKeys = [yusdacra wolumonde];
  "arpaCert.age".publicKeys = [yusdacra wolumonde];
  "arpaKey.age".publicKeys = [yusdacra wolumonde];
}
