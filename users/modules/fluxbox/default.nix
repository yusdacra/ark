{pkgs, ...}: {
  xsession.enable = true;
  xsession.windowManager.fluxbox = {
    enable = true;
    menu = ''
      [exec] (Floorp) {/etc/profiles/per-user/patriot/bin/floorp}
      [exec] (urxvt) {/etc/profiles/per-user/patriot/bin/urxvt}
    '';
  };
}
