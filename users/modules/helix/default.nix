{
  inputs,
  pkgs,
  ...
}: {
  stylix.targets.helix.enable = false;
  programs.helix = {
    enable = true;
    languages = [
      {
        name = "dockerfile";
        roots = ["Dockerfile" "Containerfile"];
        file-types = ["Dockerfile" "Containerfile" "dockerfile" "containerfile"];
      }
      {
        name = "nix";
        language-server = {command = "${inputs.nil.packages.${pkgs.system}.default}/bin/nil";};
      }
    ];
    settings = {
      theme = "ferra";
      editor = {
        soft-wrap.enable = true;
        line-number = "relative";
        middle-click-paste = false;
        true-color = true;
        whitespace.render = "all";
        cursor-shape.insert = "block";
        lsp = {
          display-messages = true;
          display-inlay-hints = false;
        };
        indent-guides = {
          render = true;
        };
        auto-pairs = {
          "(" = ")";
          "{" = "}";
          "[" = "]";
          "\"" = "\"";
          "'" = "'";
          "<" = ">";
        };
        statusline = {
          left = ["mode" "spinner"];
          center = ["file-name" "file-encoding" "version-control"];
          right = ["diagnostics" "selections"];
        };
      };
    };
  };
}
