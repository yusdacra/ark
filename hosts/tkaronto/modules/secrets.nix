{
  age.identityPaths = ["/etc/nixos/keys/ssh_key"];

  age.secrets.nixGithubAccessToken.file = ../../../secrets/nixGithubAccessToken.age;
  age.secrets.wgTkarontoKey.file = ../../../secrets/wgTkarontoKey.age;
}
