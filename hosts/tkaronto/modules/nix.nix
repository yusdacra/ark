{config, ...}: {
  nix.extraOptions = ''
    !include ${config.age.secrets.nixGithubAccessToken.path}
  '';
}
