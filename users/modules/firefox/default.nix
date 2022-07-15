{
  pkgs,
  config,
  ...
}: {
  home.persistence."${config.system.persistDir}${config.home.homeDirectory}".directories = [".mozilla"];
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland.override {
      extraPrefs = ''
        lockPref("privacy.resistFingerprinting.letterboxing", false);
        lockPref("browser.startup.homepage", "about:home");
        lockPref("browser.newtabpage.enabled", true);
        lockPref("browser.startup.page", 1);
        lockPref("privacy.clearOnShutdown.downloads", false);
        lockPref("privacy.clearOnShutdown.formdata", false);
        lockPref("privacy.clearOnShutdown.history", false);
        lockPref("privacy.clearOnShutdown.offlineApps", false);
        lockPref("privacy.clearOnShutdown.sessions", false);
        lockPref("privacy.clearOnShutdown.cookies", false);
        lockPref("services.sync.engine.passwords", false);
        lockPref("network.cookie.lifetimePolicy", 0);
      '';
      extraPolicies = {
        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = true;
        FirefoxHome = {
          Pocket = false;
          Snippets = false;
        };
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
      };
    };
    extensions = with pkgs.nur.repos.rycee.firefox-addons; let
      myExtensions =
        pkgs.callPackage ./extensions.nix {inherit buildFirefoxXpiAddon;};
    in
      [
        ublock-origin
        darkreader
        bitwarden
        refined-github
        stylus
      ]
      ++ (with myExtensions; [
        catppuccin-mocha-sky
        youtube-disable-number-seek
      ]);
    profiles = {
      default = {
        id = 0;
        isDefault = false;
        name = "defaulta";
      };
      personal = {
        id = 1;
        isDefault = true;
        name = "personal";
        extraConfig = builtins.readFile (
          builtins.fetchurl {
            url = "https://raw.githubusercontent.com/arkenfox/user.js/101.0/user.js";
            sha256 = "sha256:1mb1l9dgb8mfl70lhwykgfphqnxxi1xw0h3hlgj8jyj6n1mn5v8f";
          }
        );
      };
    };
  };
}
