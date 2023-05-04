{
  pkgs,
  inputs,
  ...
}: {
  # stylix.targets.vscode.enable = false;
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with inputs.vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
      mkhl.direnv
      bbenoist.nix
      svelte.svelte-vscode
      bradlc.vscode-tailwindcss
      (rust-lang.rust-analyzer.overrideAttrs (old: {
        src = old.src.overrideAttrs (old: {
          outputHash = "sha256-k9eDTY9y2ejg4jTApji8X6UmKYK/eCLMZJbiYuoTuyY=";
        });
      }))
      # explodingcamera."1am"
    ];
    userSettings = {
      "files.associations" = {
        "*.css" = "tailwindcss";
      };
      "editor.quickSuggestions" = {
        "strings" = "on";
      };
      "editor.suggest.showStatusBar" = true;
      "editor.formatOnSave" = true;
      # "workbench.colorTheme" = "1am";
    };
  };
}
