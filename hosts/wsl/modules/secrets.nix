{
  age.identityPaths = [ "/home/firewatch/.ssh/id_rsa" ];

  age.secrets.nixGithubAccessToken.file = ../../../secrets/nixGithubAccessToken.age;
}
