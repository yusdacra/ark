{
  imports = [./dns];
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
  };
}
