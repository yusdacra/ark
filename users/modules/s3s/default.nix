{config, inputs, ...}: {
  imports = [inputs.s3s.homeManagerModule];
  services.s3s.enable = true;
}
