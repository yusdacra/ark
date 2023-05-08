{
  age.identityPaths = ["/persist/keys/ssh_key"];

  age.secrets.nixGithubAccessToken.file = ../../../secrets/nixGithubAccessToken.age;
  age.secrets.wgTkarontoKey = {
    file = ../../../secrets/wgTkarontoKey.age;
    mode = "600";
    owner = "systemd-network";
    group = "systemd-network";
  };
}
