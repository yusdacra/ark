let
  yusdacra = builtins.readFile ./yusdacra.key.pub;
  wolumonde = builtins.readFile ./wolumonde.key.pub;
in {
  "wgWolumondeKey.age".publicKeys = [yusdacra wolumonde];
  "wgTkarontoKey.age".publicKeys = [yusdacra];
  "bernbotToken.age".publicKeys = [yusdacra wolumonde];
  "musikquadConfig.age".publicKeys = [yusdacra wolumonde];
  "nixGithubAccessToken.age".publicKeys = [yusdacra];
  "nixBuildKey.age".publicKeys = [yusdacra];
  "tmodloaderServerPass.age".publicKeys = [yusdacra wolumonde];
}
