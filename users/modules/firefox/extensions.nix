{
  buildFirefoxXpiAddon,
  fetchurl,
  lib,
  stdenv,
}: {
  "catppuccin-mocha-sky" = buildFirefoxXpiAddon {
    pname = "catppuccin-mocha-sky";
    version = "2.0";
    addonId = "{12eeb304-58cd-4bcb-9676-99562b04f066}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3954372/catppuccin_dark_sky-2.0.xpi";
    sha256 = "d9453ae265608d3a1b17c812d77422ab2aaf357365e527812268a407643efa25";
    meta = with lib; {
      description = "Firefox theme based on <a href=\"https://outgoing.prod.mozaws.net/v1/110954a3f2718cf03892676379416caed51099b639f643aaf12989b7e698f073/https%3A//github.com/catppuccin/catppuccin\" rel=\"nofollow\">https://github.com/catppuccin/catppuccin</a>";
      platforms = platforms.all;
    };
  };
  "youtube-disable-number-seek" = buildFirefoxXpiAddon {
    pname = "youtube-disable-number-seek";
    version = "1.1";
    addonId = "{963aa3d4-c342-4dfe-872e-76be742d1bea}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3592479/youtube_disable_number_seek-1.1.xpi";
    sha256 = "28075f68438242615cbe857e52c3ae1f661447c7d066d4ef4e5076b44efad07a";
    meta = with lib; {
      description = "Disables 0-9 keyboard shortcuts on YouTube which seek to different times on a video.";
      license = licenses.mpl20;
      platforms = platforms.all;
    };
  };
}
