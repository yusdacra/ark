{ ... }:
{
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "tr_TR.UTF-8/UTF-8"
    ];
  };
  time.timeZone = "Turkey";
  services.xserver.xkb.layout = "us";
  console.keyMap = "us";
}
