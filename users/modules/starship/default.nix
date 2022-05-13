{...}: {
  programs.starship = {
    enable = true;
    settings = {
      format = "$shell$shlvl$nix_shell@ $directory$character";
      add_newline = false;
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
      };
      shell.disabled = false;
      shlvl = {
        disabled = false;
        symbol = "shlvl ";
        format = "on [$symbol$shlvl]($style) ";
      };
      nix_shell.format = "via [$name]($style) ";
      directory = {
        truncation_length = 2;
        truncate_to_repo = false;
      };
    };
  };
}
