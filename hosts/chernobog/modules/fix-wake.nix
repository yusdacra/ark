{
  services.udev.extraRules = ''
    ACTION=="add", KERNELS=="0000:00:01.1", ATTR{power/wakeup}="disabled"
  '';
}
