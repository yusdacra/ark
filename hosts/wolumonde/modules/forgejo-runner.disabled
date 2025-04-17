{pkgs, config, ...}: {
  services.gitea-actions-runner.package = pkgs.forgejo-runner;
  services.gitea-actions-runner.instances."thermex" = {
    enable = true;
    url = config.services.forgejo.settings.server.ROOT_URL;
    name = "thermex";
    tokenFile = config.age.secrets.forgejoActRunnerToken.path;
    labels = ["docker:docker://yusdacra/lixpine:latest"];
    settings.container.privileged = true;
  };
}
