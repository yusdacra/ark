{
  buildFirefoxXpiAddon,
  fetchurl,
  lib,
  stdenv,
}: {
  "better-clean-twitter" = buildFirefoxXpiAddon {
    pname = "better-clean-twitter";
    version = "1.3.2";
    addonId = "bct@presti.me";
    url = "https://addons.mozilla.org/firefox/downloads/file/4124387/better_clean_twitter-1.3.2.xpi";
    sha256 = "094d99c7678c3247a0b07a2d0d942df969daafe567d392a52a6f0b40ce7382bd";
    meta = with lib; {
      homepage = "https://presti.me";
      description = "Remove all the annoying clutter from your Twitter.";
      license = licenses.gpl3;
      mozPermissions = [
        "*://twitter.com/*"
        "*://api.twitter.com/*"
        "activeTab"
        "storage"
        "tabs"
        "scripting"
        "webRequest"
        "nativeMessaging"
        "https://twitter.com/*"
      ];
      platforms = platforms.all;
    };
  };
  "better-twitter-extension" = buildFirefoxXpiAddon {
    pname = "better-twitter-extension";
    version = "2.1.2";
    addonId = "{ef32ca60-1728-4011-a585-4de439fe7ba7}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4056346/better_twitter_extension-2.1.2.xpi";
    sha256 = "25cf90586def269d7a54d8b4fd71aa63529e25ed6689df4c05b0d7f8c3fabca9";
    meta = with lib; {
      description = "Hide what is not important on <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/26ca20fd517be4e3078c65b14f44521b572c8c48532db6c37d90ff3a2ee15167/http%3A//Twitter.com\" rel=\"nofollow\">Twitter.com</a>";
      mozPermissions = [
        "storage"
        "https://twitter.com/*"
        "https://mobile.twitter.com/*"
      ];
      platforms = platforms.all;
    };
  };
  "catppuccin-mocha-sky" = buildFirefoxXpiAddon {
    pname = "catppuccin-mocha-sky";
    version = "2.0";
    addonId = "{12eeb304-58cd-4bcb-9676-99562b04f066}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3954372/catppuccin_dark_sky-2.0.xpi";
    sha256 = "d9453ae265608d3a1b17c812d77422ab2aaf357365e527812268a407643efa25";
    meta = with lib; {
      description = "Firefox theme based on <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/110954a3f2718cf03892676379416caed51099b639f643aaf12989b7e698f073/https%3A//github.com/catppuccin/catppuccin\" rel=\"nofollow\">https://github.com/catppuccin/catppuccin</a>";
      license = licenses.cc-by-30;
      mozPermissions = [];
      platforms = platforms.all;
    };
  };
  "showdex" = buildFirefoxXpiAddon {
    pname = "showdex";
    version = "1.1.6";
    addonId = "showdex@tize.io";
    url = "https://addons.mozilla.org/firefox/downloads/file/4146071/showdex-1.1.6.xpi";
    sha256 = "1d608d261c73f8acac4c2f3a878c501d822ae6dc6f0e3f018b07bc6eada646a4";
    meta = with lib; {
      homepage = "https://github.com/doshidak/showdex";
      description = "Pokémon Showdown extension that harnesses the power of parabolic calculus to strategically extract your opponents' Elo.";
      mozPermissions = [
        "clipboardRead"
        "clipboardWrite"
        "*://play.pokemonshowdown.com/*"
        "*://*.psim.us/*"
        "*://play.radicalred.net/*"
      ];
      platforms = platforms.all;
    };
  };
  "styl-us" = buildFirefoxXpiAddon {
    pname = "styl-us";
    version = "1.5.35";
    addonId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4160414/styl_us-1.5.35.xpi";
    sha256 = "d415ee11fa4a4313096a268e54fd80fa93143345be16f417eb1300a6ebe26ba1";
    meta = with lib; {
      homepage = "https://add0n.com/stylus.html";
      description = "Redesign your favorite websites with Stylus, an actively developed and community driven userstyles manager. Easily install custom themes from popular online repositories, or create, edit, and manage your own personalized CSS stylesheets.";
      license = licenses.gpl3;
      mozPermissions = [
        "tabs"
        "webNavigation"
        "webRequest"
        "webRequestBlocking"
        "contextMenus"
        "storage"
        "unlimitedStorage"
        "alarms"
        "<all_urls>"
        "http://userstyles.org/*"
        "https://userstyles.org/*"
      ];
      platforms = platforms.all;
    };
  };
  "youtube-disable-number-seek" = buildFirefoxXpiAddon {
    pname = "youtube-disable-number-seek";
    version = "1.2";
    addonId = "{963aa3d4-c342-4dfe-872e-76be742d1bea}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4134869/youtube_disable_number_seek-1.2.xpi";
    sha256 = "d6cde501b2603944e36baaa10adb9f24c9214929929c346176d0336d25418259";
    meta = with lib; {
      description = "Disables 0-9 keyboard shortcuts on YouTube which seek to different times on a video.";
      license = licenses.mpl20;
      mozPermissions = [
        "*://*.youtube.com/*"
        "*://*.youtube-nocookie.com/*"
      ];
      platforms = platforms.all;
    };
  };
}
