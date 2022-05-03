{...}: {
  programs.starship = {
    enable = true;
    settings = {
      format = "$shell$nix_shell$shlvl@ $directory> ";
      add_newline = false;
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
      };
      shell.disabled = false;
      shlvl.disabled = false;
      nix_shell.format = "via [$name]($style) ";
      directory = {
        truncation_length = 2;
        truncate_to_repo = false;
      };
    };
  };
}
