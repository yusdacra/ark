{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ kakoune ];

  environment.sessionVariables = {
    EDITOR = "${pkgs.kakoune}/bin/kak";
    VISUAL = "${pkgs.kakoune}/bin/kak";
  };

  environment.shellAliases = { k = "${pkgs.kakoune}/bin/kak"; };
}
