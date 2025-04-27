{ lib, pkgs, ... }:
{
  environment.shells = [pkgs.nushell];
  users.users.root.shell = pkgs.nushell;

  home-manager.users.root = {
    programs.nushell = {
      enable = true;
      package = pkgs.nushell;
      shellAliases = {
        myip = lib.mkForce "echo";
      };
      extraEnv = ''
        source-env ${./prompt.nu}
      '';
      extraConfig = ''
        let carapace_completer = {|spans: list<string>|
          carapace $spans.0 nushell ...$spans
          | from json
          | if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
        }
        $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

        let fish_completer = {|spans|
          ${lib.getExe pkgs.fish} --command $'complete "--do-complete=($spans | str join " ")"'
          | $"value(char tab)description(char newline)" + $in
          | from tsv --flexible --no-infer
        }

        let zoxide_completer = {|spans|
            $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
        }

        let multiple_completers = {|spans|
          ## alias fixer start https://www.nushell.sh/cookbook/external_completers.html#alias-completions
          let expanded_alias = scope aliases
          | where name == $spans.0
          | get -i 0.expansion

          let spans = if $expanded_alias != null {
            $spans
            | skip 1
            | prepend ($expanded_alias | split row ' ' | take 1)
          } else {
            $spans
          }
          ## alias fixer end

          match $spans.0 {
            __zoxide_z | __zoxide_zi => $zoxide_completer
            _ => $carapace_completer
          } | do $in $spans
        }

        $env.config = {
          show_banner: false,
          completions: {
            case_sensitive: false # case-sensitive completions
            quick: true           # set to false to prevent auto-selecting completions
            partial: true         # set to false to prevent partial filling of the prompt
            algorithm: "fuzzy"    # prefix or fuzzy
            external: {
              # set to false to prevent nushell looking into $env.PATH to find more suggestions
              enable: true 
              # set to lower can improve completion performance at the cost of omitting some options
              max_results: 100 
              completer: $multiple_completers
            }
          }
        } 
        $env.PATH = ($env.PATH | 
          split row (char esep) |
          append /usr/bin/env
        )

        source ${./aliases.nu}
      '';
    };
    programs.carapace.enable = true;
    programs.carapace.enableNushellIntegration = true;
  };
}
