{
  hardware.amdgpu.overdrive.enable = true;

  services.lact.enable = true;
  environment.etc."lact/config.yaml".source = ./config.yaml;
}
