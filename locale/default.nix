{...}: {
  i18n = {
    defaultLocale = "tr_TR.UTF-8";
    supportedLocales = ["tr_TR.UTF-8/UTF-8" "en_US.UTF-8/UTF-8"];
  };
  time.timeZone = "Turkey";
  services.xserver.layout = "tr";
  console.keyMap = "trq";
}
