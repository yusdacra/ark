{
  inputs,
  pkgs,
  ...
}: {
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
      {
        name = "rust";
        language-server = {command = "${pkgs.rust-analyzer}/bin/rust-analyzer";};
      }
    ];
    settings = {
      editor = {
        line-number = "relative";
        middle-click-paste = false;
        true-color = true;
        whitespace.render = "all";
        cursor-shape.insert = "bar";
        lsp.display-messages = true;
        indent-guides = {
          render = true;
          character = "|";
        };
        auto-pairs = {
          "(" = ")";
          "{" = "}";
          "[" = "]";
          "\"" = "\"";
          "'" = "'";
          "<" = ">";
        };
      };
    };
  };
}
