{
  programs.git = {
    enable = true;
    extraConfig = {pull.rebase = true;};
    lfs.enable = true;
    aliases = {
      a = "add -p";
      co = "checkout";
      cob = "checkout -b";
      f = "fetch -p";
      c = "commit";
      ps = "push";
      pl = "pull";
      rb = "rebase";
      ba = "branch -a";
      bd = "branch -d";
      bD = "branch -D";
      d = "diff";
      dc = "diff --cached";
      ds = "diff --staged";
      rs = "restore";
      rss = "restore --staged";
      s = "status -sb";
      ss = "stash";
      ssp = "stash pop";
      ssl = "stash list";
      ssd = "stash drop";
      # reset
      rsoft = "reset --soft";
      rhard = "reset --hard";
      rs1ft = "soft HEAD~1";
      rh1rd = "hard HEAD~1";
      # logging
      l = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      plog = "log --graph --pretty='format:%C(red)%d%C(reset) %C(yellow)%h%C(reset) %ar %C(green)%aN%C(reset) %s'";
      tlog = "log --stat --since='1 Day Ago' --graph --pretty=oneline --abbrev-commit --date=relative";
      rank = "shortlog -sn --no-merges";
      # delete merged branches
      bdm = "!git branch --merged | grep -v '*' | xargs -n 1 git branch -d";
    };
  };
}
