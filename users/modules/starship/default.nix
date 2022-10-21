{...}: {
  programs.starship = {
    enable = true;
    settings = {
      format = "$directory$character";
      add_newline = false;
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
      };
      directory = {
        truncation_length = 2;
        truncate_to_repo = false;
      };
    };
  };
}
